using System;
using System.Collections.Generic;
using System.Data;
using System.Windows.Forms;
using Controls;
using Shipping.Properties;
using SymbolRFGun;
using Connection;
using DataGridCustomColumns;
using DataLayer.DataAccess;

namespace Shipping
{
    public class Controller
    {
        #region Class Objects

        private formShipping shippingForm;
        private MessageController messageController;
        private ErrorAlert alert;

        private readonly DataLayer.DataAccess.Location location;
        private readonly DataLayer.DataAccess.Shipping shipping;

        #endregion


        public string OperatorCode { private get; set; }

        //public int ShipperID { get; set; }

        //private bool isDatabindingCycleCountList { get; set; }

        //private string selectedCycleCount;
        //public string SelectedCycleCount
        //{
        //    get { return selectedCycleCount; }
        //    set
        //    {
        //        selectedCycleCount = value;
        //        if (!isDatabindingCycleCountList)
        //        {
        //            ClearForm();
        //        }
        //    }
        //}


        enum alertLevel
        {
            Medium,
            High
        }


        #region ScreenStates
        enum screenStates
        {
            pendingLogin,
            loggedIn,
            shipperSelected,
            refreshScreen
        }

        private screenStates _screenState;
        private screenStates ScreenState
        {
            get { return _screenState; }
            set
            {
                _screenState = value;
                switch (_screenState)
                {
                    case screenStates.pendingLogin:
                        shippingForm.cbxShippers.DataSource = shippingForm.cbxSerials.DataSource =
                            shippingForm.gridLines.DataSource = shippingForm.gridObjects.DataSource = null;

                        shippingForm.pnlMain.Enabled = false;
                        
                        messageController.ShowInstruction(Resources.loginInstructions);
                        shippingForm.logOnOffControl1.txtOperator.Focus();
                        break;
                    case screenStates.loggedIn:
                        shippingForm.pnlMain.Enabled = true;
                        messageController.ShowInstruction(Resources.scanShipper);
                        GetShipperNumbers();
                        break;
                    case screenStates.shipperSelected:
                        messageController.ShowInstruction(Resources.scanObject);
                        break;
                    case screenStates.refreshScreen:
                        //shippingForm.tbxLocation.Text = shippingForm.tbxSerial.Text = "";
                        messageController.ShowInstruction(Resources.scanShipper);
                        //GetCycleCountList();
                        break;
                }
            }
        }
        #endregion


        public Controller()
        {
            // Instantiate declared class objects
            shippingForm = new formShipping(this);
            location = new DataLayer.DataAccess.Location();
            shipping = new DataLayer.DataAccess.Shipping();
            alert = new ErrorAlert();
            messageController = new MessageController(shippingForm.messageBoxControl1.ucMessageBox, Resources.loginInstructions);
            ScreenState = screenStates.pendingLogin;

            // Wire control events
            shippingForm.logOnOffControl1.LogOnOffChanged += new LogOnOffControl.LogOnOffChangedEventHandler(logOnOffControl1_LogOnOffChanged);
            shippingForm.logOnOffControl1.OperatorCodeChanged += new LogOnOffControl.OperatorCodeChangedEventHandler(logOnOffControl1_OperatorCodeChanged);
            shippingForm.messageBoxControl1.MessageBoxControl_ShowPrevMessage += new EventHandler<EventArgs>(messageBoxControl1_MessageBoxControl_ShowPrevMessage);
            shippingForm.messageBoxControl1.MessageBoxControl_ShowNextMessage += new EventHandler<EventArgs>(messageBoxControl1_MessageBoxControl_ShowNextMessage);

            Application.Run(shippingForm);
        }





        void messageBoxControl1_MessageBoxControl_ShowNextMessage(object sender, EventArgs e)
        {
            messageController.ShowNextMessage();
        }

        void messageBoxControl1_MessageBoxControl_ShowPrevMessage(object sender, EventArgs e)
        {
            messageController.ShowPreviousMessage();
        }





        void logOnOffControl1_LogOnOffChanged(bool state)
        {
            if (state) // A user successfully logged on
            {
                FXRFGlobals.MyRFGun.StartRead();

                // Enable controls
                ScreenState = screenStates.loggedIn;
            }
            else // A user logged off
            {
                FXRFGlobals.MyRFGun.StopRead();

                // Disable and clear controls until a user logs on again
                ScreenState = screenStates.pendingLogin;
            }
        }

        void logOnOffControl1_OperatorCodeChanged(string opCode)
        {
            OperatorCode = opCode;
        }




        #region Shipper Methods

        public void GetShipperNumbers()
        {
            string error = "";

            var shipperNumbers = shipping.GetShipperNumbers(out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, error, "GetShipperNumbers() Error");
                return;
            }
            if (shipperNumbers == null)
            {
                alert.ShowError(alertLevel.High, "There are no active Shippers.", "GetShipperNubmers() Error");
                return;
            }
            shippingForm.cbxShippers.DataSource = shipperNumbers;
            shippingForm.cbxShippers.DisplayMember = "id";
            shippingForm.cbxShippers.ValueMember = "id";
            shippingForm.cbxShippers.SelectedItem = null;
        }

        public void GetShipperLines()
        {
            string error = "";
            int shipperID = Convert.ToInt32(shippingForm.cbxShippers.SelectedValue);

            var shipperLines = shipping.GetShipperLines(shipperID, out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, error, "GetShipperLines() Error");
                return;
            }
            if (shipperLines == null)
            {
                alert.ShowError(alertLevel.High, "There are no active Shipper Lines.", "GetShipperLines() Error");
                return;
            }

            // Customize datagrid columns
            CustomDataGridColumnStyles(shipperLines);

            // Bind datagrid
            shippingForm.gridLines.DataSource = shipperLines;

            ScreenState = screenStates.shipperSelected;
        }

        private void CustomDataGridColumnStyles(DataTable dt)
        {
            shippingForm.gridLines.TableStyles.Clear();
            var ts = new DataGridTableStyle { MappingName = "GetShipperLines" };


            // Part Column
            var dataGridCustomColumn0 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridLines,
                HeaderText = "Part",
                MappingName = "part",
                Width = shippingForm.gridLines.Width * 18 / 100,
                ReadOnly = true
            };
            //dataGridCustomColumn0.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn0);


            // Customer Part Column
            var dataGridCustomColumn1 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridLines,
                HeaderText = "CPart",
                MappingName = "customer_part",
                Width = shippingForm.gridLines.Width * 35 / 100,
                ReadOnly = true
            };
            //dataGridCustomColumn1.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn1);


            // Quantity Required Column
            var dataGridCustomColumn2 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridLines,
                HeaderText = "Rqd",
                Format = "0.#",
                FormatInfo = null,
                MappingName = "qty_required",
                Width = shippingForm.gridLines.Width * 15 / 100,
                Alignment = HorizontalAlignment.Right,
                ReadOnly = true
            };
            //dataGridCustomColumn2.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn2);


            // Quantity Packed Column
            var dataGridCustomColumn3 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridLines,
                HeaderText = "Pkd",
                Format = "0.#",
                FormatInfo = null,
                MappingName = "qty_packed",
                Width = shippingForm.gridLines.Width * 15 / 100,
                Alignment = HorizontalAlignment.Right,
                ReadOnly = true
            };
            //dataGridCustomColumn3.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn3);


            // Boxes Staged Column
            var dataGridCustomColumn4 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridLines,
                HeaderText = "Staged",
                MappingName = "boxes_staged",
                Width = shippingForm.gridLines.Width * 18 / 100,
                ReadOnly = true
            };
            //dataGridCustomColumn4.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn4);

            //  Add new table style to Grid.
            shippingForm.gridLines.TableStyles.Add(ts);
        }


        //public void GetCycleCountList()
        //{
        //    string error = "";
        //    isDatabindingCycleCountList = true;

        //    var cycleCountNumbers = cycle.GetCycleCountNumbers(out error);
        //    if (error != "")
        //    {
        //        alert.ShowError(alertLevel.High, error, "GetCycleCountList() Error");
        //        return;
        //    }
        //    if (cycleCountNumbers == null)
        //    {
        //        alert.ShowError(alertLevel.High, "There are no active Cycle Counts.", "GetCycleCountList() Error");
        //        return;
        //    }
        //    cycleCountForm.cbxCycleCount.DataSource = cycleCountNumbers;
        //    cycleCountForm.cbxCycleCount.DisplayMember = "Description";
        //    cycleCountForm.cbxCycleCount.ValueMember = "CycleCountNumber";

        //    SelectedCycleCount = cycleCountForm.cbxCycleCount.SelectedValue.ToString();
        //    cycleCountForm.pnlDataForm.Enabled = true;
        //    cycleCountForm.tbxLocation.Focus();

        //    isDatabindingCycleCountList = false;
        //}

        #endregion



        #region Serial Methods

        //public void SerialEntered(int serial)
        //{
        //    if (LastSerial == null)
        //    {
        //        // Prepare current serial for Cycle Count
        //        GetObjectInfo(serial);
        //    }
        //    else
        //    {
        //        // Add the previous serial to the Cycle Count, prepare current serial for Cycle Count
        //        CycleCountTheObject();
        //        GetObjectInfo(serial);
        //    }
        //}

        //private void GetObjectInfo(int serial)
        //{
        //    string part, quantity, loc, error = "";

        //    cycle.GetObjectInfo(serial, out part, out quantity, out loc, out error);
        //    if (error != "")
        //    {
        //        alert.ShowError(alertLevel.High, error, "GetObjectInfo() Error");
        //        cycleCountForm.tbxSerial.Text = "";
        //        return;
        //    }
        //    LastSerial = serial;
        //    cycleCountForm.tbxPart.Text = part;
        //    cycleCountForm.tbxQuantity.Text = quantity;
        //    cycleCountForm.tbxRealQuantity.Focus();
        //}

        //public void CycleCountTheObject()
        //{
        //    decimal realquantity = -1;
        //    if (cycleCountForm.tbxRealQuantity.Text.Trim() != "")
        //    {
        //        realquantity = ValidateQuantity(cycleCountForm.tbxRealQuantity.Text.Trim());
        //        if (realquantity < 0)
        //        {
        //            alert.ShowError(alertLevel.Medium, "Real quantity is not valid.", "Error");
        //            return;
        //        }
        //    }

        //    string error = "";
        //    string actionTakenMessage = "";
        //    int? actionTaken = null;
        //    string ccnumber = cycleCountForm.cbxCycleCount.SelectedValue.ToString();
        //    string part = cycleCountForm.tbxPart.Text;
        //    string loc = cycleCountForm.tbxLocation.Text.Trim();
        //    int lastserial = Convert.ToInt32(LastSerial);

        //    if (realquantity < 0)
        //    {
        //        decimal quantity = Convert.ToDecimal(cycleCountForm.tbxQuantity.Text.Trim());
        //        int? result = cycle.CycleCountTheObject(OperatorCode, ccnumber, lastserial, part, quantity, loc, out actionTakenMessage, out actionTaken, out error);
        //        if (error != "")
        //        {
        //            alert.ShowError(alertLevel.High, error, "CycleCountTheObject() Error");
        //        }
        //        else
        //        {
        //            messageController.ShowMessage(actionTakenMessage);
        //        }
        //    }
        //    else
        //    {
        //        int? result = cycle.CycleCountTheObject(OperatorCode, ccnumber, lastserial, part, realquantity, loc, out actionTakenMessage, out actionTaken, out error);
        //        if (error != "")
        //        {
        //            alert.ShowError(alertLevel.High, error, "CycleCountTheObject() Error");
        //        }
        //        else
        //        {
        //            messageController.ShowMessage(actionTakenMessage);
        //        }
        //    }
        //}

        //public int ValidateSerial(string ser)
        //{
        //    int serial = 0;
        //    try
        //    {
        //        serial = Convert.ToInt32(ser);
        //    }
        //    catch (Exception)
        //    {
        //        return serial;
        //    }
        //    return serial;
        //}

        //private decimal ValidateQuantity(string qty)
        //{
        //    decimal quantity = -1;
        //    try
        //    {
        //        quantity = Convert.ToDecimal(qty);
        //    }
        //    catch (Exception)
        //    {
        //        return quantity;
        //    }
        //    return quantity;
        //}

        #endregion



        #region Additional Methods

        public void handleScan(RFScanEventArgs e)
        {
            try
            {
                ScanData scanData = e.Text;

                if (scanData.ScanDataType == eScanDataType.Serial || scanData.ScanDataType == eScanDataType.Undef)
                {
                    int serial = int.Parse(scanData.DataValue.Trim());
                    //cycleCountForm.tbxSerial.Text = scanData.DataValue.Trim();
                    //SerialEntered(serial);
                }
                else if (scanData.ScanDataType == eScanDataType.Shipper)
                {
                    //cycleCountForm.tbxLocation.Text = scanData.DataValue.Trim();
                    //LocationEntered(scanData.DataValue.Trim());
                }
                else
                {
                    alert.ShowError(alertLevel.High, "Invalid scan.", "Error");
                }
            }
            catch (Exception ex)
            {
                if (ex.InnerException != null)
                {
                    alert.ShowError(alertLevel.High, ex.InnerException.ToString(), "handleScan() Error");
                }
                else
                {
                    alert.ShowError(alertLevel.High, ex.Message, "handleScan() Error");
                }
            }
        }

        public void RefreshScreen()
        {
            ScreenState = screenStates.refreshScreen;
        }

        public void DisplayErrorMessageFromForm(Enum alertLevel, string message)
        {
            alert.ShowError(alertLevel, message, "Message");
        }

        #endregion


    }
}
