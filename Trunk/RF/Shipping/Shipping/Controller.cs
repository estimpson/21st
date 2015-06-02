using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Reflection;
using System.Windows.Forms;
using Controls;
using Shipping.Properties;
using SymbolRFGun;
using Connection;
using DataGridCustomColumns;
using DataLayer.DataAccess;
using DataLayer.dsShippingTableAdapters;
using DataLayer;

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

        private DataTable dataTableShipperLines;

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
                        shippingForm.cbxShippers.DataSource = shippingForm.gridLines.DataSource = 
                            shippingForm.gridObjects.DataSource = null;

                        shippingForm.tbxSerial.Text = "";

                        shippingForm.pnlMain.Enabled = shippingForm.pnlObjects.Enabled = false;
                        
                        messageController.ShowInstruction(Resources.loginInstructions);
                        shippingForm.logOnOffControl1.txtOperator.Focus();
                        break;
                    case screenStates.loggedIn:
                        shippingForm.pnlMain.Enabled = true;
                        messageController.ShowInstruction(Resources.scanShipper);
                        GetShipperNumbers();
                        break;
                    case screenStates.shipperSelected:
                        shippingForm.pnlObjects.Enabled = true;

                        // Clear staged objects grid until a shipper line is selected
                        shippingForm.gridObjects.DataSource = null;

                        messageController.ShowInstruction(Resources.scanObject);
                        break;
                    case screenStates.refreshScreen:
                        shippingForm.cbxShippers.DataSource = shippingForm.gridLines.DataSource =
                            shippingForm.gridObjects.DataSource = null;

                        shippingForm.tbxSerial.Text = "";

                        shippingForm.pnlObjects.Enabled = false;

                        GetShipperNumbers();

                        messageController.ShowInstruction(Resources.scanShipper);
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
                     
        public void ShipperScanned(string shipper)        
        {
            // Validate shipper and get shipper lines
            GetShipperLines();

            // Refresh combobox
            GetShipperNumbers();

            // Set combobox text
            shippingForm.cbxShippers.Text = shipper;
        }

        public void GetShipperLines()
        {
            string error = "";
            string customer = "";
            string duedate = "";
            int shipperID = Convert.ToInt32(shippingForm.cbxShippers.SelectedValue);

            var shipperLines = shipping.GetShipperLines(shipperID, out customer, out duedate, out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, error, "GetShipperLines() Error");
                return;
            }
            if (shipperLines == null)
            {
                alert.ShowError(alertLevel.High, "Failed to return any Shipper Lines.", "GetShipperLines() Error");
                return;
            }
            dataTableShipperLines = shipperLines;

            // Customize datagrid columns
            CustomDataGridColumnStyles();

            // Bind datagrid
            shippingForm.gridLines.DataSource = shipperLines;

            ScreenState = screenStates.shipperSelected;
            messageController.ShowMessage(string.Format("Now staging Shipper {0}, Customer {1}, Due {2}.", shipperID, customer, duedate));
        }

        private void CustomDataGridColumnStyles()
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
            dataGridCustomColumn0.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn0);


            // Customer Part Column
            var dataGridCustomColumn1 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridLines,
                HeaderText = "CPart",
                MappingName = "customer_part",
                Width = shippingForm.gridLines.Width * 30 / 100,
                ReadOnly = true
            };
            dataGridCustomColumn1.SetCellFormat += CgsSetCellFormat;
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
            dataGridCustomColumn2.SetCellFormat += CgsSetCellFormat;
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
            dataGridCustomColumn3.SetCellFormat += CgsSetCellFormat;
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
            dataGridCustomColumn4.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn4);

            //  Add new table style to Grid.
            shippingForm.gridLines.TableStyles.Add(ts);
        }

        // Define Event Handler. It must conform to the paramters defined in the delegate.
        private void CgsSetCellFormat(object sender, DataGridCustomColumns.DataGridFormatCellEventArgs e)
        {
            var rowShipperLines = dataTableShipperLines.Rows[e.Row] as DataLayer.dsShipping.GetShipperLinesRow;

            try
            {
                decimal d = Convert.ToDecimal(rowShipperLines.qty_packed);
            }
            catch (Exception)
            {
                e.CellColor = Color.White;
                return;
            }

            if (rowShipperLines.qty_packed == 0)
            {
                e.CellColor = Color.White;
                return;
            }

            if (rowShipperLines.qty_packed < rowShipperLines.qty_required) e.CellColor = Color.Yellow;
            if (rowShipperLines.qty_packed == rowShipperLines.qty_required) e.CellColor = Color.LightGreen;
            if (rowShipperLines.qty_packed > rowShipperLines.qty_required) e.CellColor = Color.Tomato;
        }

        #endregion



        #region Serial Methods

        public void GetObjects(string part) // Get list of staged objects for the shipper/part
        {
            string error = "";
            int shipperID = Convert.ToInt32(shippingForm.cbxShippers.SelectedValue);

            var shipperLineObjects = shipping.GetShipperLineObjects(shipperID, part, out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, error, "GetShipperLineObjects() Error");
                return;
            }
            if (shipperLineObjects == null) return;

            // Customize datagrid columns
            CustomDataGridColumnStylesForLineObjects();

            // Bind datagrid
            shippingForm.gridObjects.DataSource = shipperLineObjects;

            // Set form focus
            shippingForm.tbxSerial.Focus();
        }

        private void CustomDataGridColumnStylesForLineObjects()
        {
            shippingForm.gridObjects.TableStyles.Clear();
            var ts = new DataGridTableStyle { MappingName = "GetShipperLineObjects" };

            // Serial Column
            var dataGridCustomColumn0 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridObjects,
                HeaderText = "Serial",
                MappingName = "serial",
                Width = shippingForm.gridObjects.Width * 25 / 100,
                ReadOnly = true
            };
            //dataGridCustomColumn0.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn0);

            // Part Column
            var dataGridCustomColumn1 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridObjects,
                HeaderText = "Part",
                MappingName = "part",
                Width = shippingForm.gridObjects.Width * 35 / 100,
                ReadOnly = true
            };
            //dataGridCustomColumn1.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn1);

            // Quantity Column
            var dataGridCustomColumn2 = new DataGridCustomTextBoxColumn
            {
                Owner = shippingForm.gridObjects,
                HeaderText = "Qty",
                Format = "0.#",
                FormatInfo = null,
                MappingName = "quantity",
                Width = shippingForm.gridObjects.Width * 18 / 100,
                Alignment = HorizontalAlignment.Right,
                ReadOnly = true
            };
            //dataGridCustomColumn2.SetCellFormat += CgsSetCellFormat;
            ts.GridColumnStyles.Add(dataGridCustomColumn2);

            //  Add new table style to Grid.
            shippingForm.gridObjects.TableStyles.Add(ts);
        }

        public void StageOrUnstageSerial(int serial)
        {
            string error = "";
            int shipperID = Convert.ToInt32(shippingForm.cbxShippers.SelectedValue);

            int result = shipping.StageObject(OperatorCode, shipperID, serial, null, out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, string.Format("Serial {0} was not staged. ", serial) + error, "StageObject() Error");
                return;
            }

            if (result == 100) // Unstage object
            {
                // Show pop-up dialog to verify unstage
                FXRFGlobals.MyRFGun.Beep();
                DialogResult dr = MessageBox.Show("Object is already staged. Do you want to unstage it?", "Message",
                                MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                if (dr == DialogResult.Yes)
                {
                    shipping.UnstageObject(OperatorCode, serial, out error);
                    if (error != "")
                    {
                        alert.ShowError(alertLevel.High, string.Format("Serial {0} was not unstaged. ", serial) + error, "UnstageObject() Error");
                    }
                    else // Successful unstage
                    {
                        RefreshAfterStageOrUnstage(serial);
                        messageController.ShowMessage(string.Format("Unstaged {0} from Shipper {1}.", serial, shipperID));
                    }
                }  
                shippingForm.tbxSerial.Text = "";
            }
            else if (result == 0) // Successful stage
            {
                RefreshAfterStageOrUnstage(serial);
                messageController.ShowMessage(string.Format("Staged {0} to Shipper {1}.", serial, shipperID));
            }
        }

        private void RefreshAfterStageOrUnstage(int serial)
        {
            string err = "";
            shippingForm.tbxSerial.Text = "";

            // Refresh shipper lines grid
            GetShipperLines();

            // Scroll to row in lines grid based on part number of scanned serial
            var part = shipping.GetObjectInfo(serial, out err);
            if (err != "")
            {
                alert.ShowError(alertLevel.High, err, "GetShipperLineObjects() Error");
                return;
            }
            if (part == "") return;

            for (int i = 0; i < shippingForm.gridLines.VisibleRowCount; i++)
            {
                if (shippingForm.gridLines[i, 0].ToString() == part)
                    ScrollGridToRow(shippingForm.gridLines, i);
            }

            // Refresh staged objects grid
            GetObjects(part);
        }

        private void ScrollGridToRow(DataGrid control, int rowNumber)
        {
            FieldInfo fi = control.GetType().GetField("m_sbVert",
                                                   BindingFlags.NonPublic | BindingFlags.GetField |
                                                   BindingFlags.Instance);
            ((VScrollBar)fi.GetValue(shippingForm.gridLines)).Value = rowNumber;
        }

        public int ValidateSerial(string ser)
        {
            int serial = 0;
            try
            {
                serial = Convert.ToInt32(ser);
            }
            catch (Exception)
            {
                return serial;
            }
            return serial;
        }

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
                    shippingForm.tbxSerial.Text = scanData.DataValue.Trim();
                    StageOrUnstageSerial(serial);
                }
                else if (scanData.ScanDataType == eScanDataType.Shipper)
                {
                    ShipperScanned(scanData.DataValue.Trim());
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
