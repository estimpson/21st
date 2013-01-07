using System;
using System.Collections.Generic;
using System.Windows.Forms;
using Controls;
using SymbolRFGun;
using Connection;
using DataLayer.DataAccess;

namespace CycleCount
{
    public class Controller
    {
        #region Class Objects

        private formCycleCount cycleCountForm;
        private MessageController messageController;
        private ErrorAlert alert;

        private readonly DataLayer.DataAccess.Location location;
        private readonly DataLayer.DataAccess.CycleCount cycle;

        #endregion


        public string OperatorCode { private get; set; }
        public bool IsBoxFlagged { private get; set; }
        public int? LastSerial { private get; set; }

        private bool isDatabindingCycleCountList { get; set; }

        private string selectedCycleCount;
        public string SelectedCycleCount
        {
            get { return selectedCycleCount; }
            set
            {
                selectedCycleCount = value;
                if (!isDatabindingCycleCountList)
                {
                    ClearForm();
                }
            }
        }


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
                        ClearForm();
                        cycleCountForm.cbxCycleCount.DataSource = null;
                        cycleCountForm.pnlMain.Enabled = cycleCountForm.pnlDataForm.Enabled = false;
                        messageController.ShowInstruction(Resources.loginInstructions);
                        cycleCountForm.logOnOffControl1.txtOperator.Focus();
                        break;
                    case screenStates.loggedIn:
                        cycleCountForm.pnlMain.Enabled = true;
                        messageController.ShowInstruction(Resources.scanningInstructions);
                        GetCycleCountList();
                        break;
                    case screenStates.refreshScreen:
                        cycleCountForm.tbxLocation.Text = cycleCountForm.tbxSerial.Text = "";
                        messageController.ShowInstruction(Resources.scanningInstructions);
                        GetCycleCountList();
                        break;
                }
            }
        }
        #endregion


        public Controller()
        {
            // Instantiate declared class objects
            cycleCountForm = new formCycleCount(this);
            location = new DataLayer.DataAccess.Location();
            cycle = new DataLayer.DataAccess.CycleCount();
            alert = new ErrorAlert();
            messageController = new MessageController(cycleCountForm.messageBoxControl1.ucMessageBox, Resources.loginInstructions);
            ScreenState = screenStates.pendingLogin;

            // Wire control events
            cycleCountForm.logOnOffControl1.LogOnOffChanged += new LogOnOffControl.LogOnOffChangedEventHandler(logOnOffControl1_LogOnOffChanged);
            cycleCountForm.logOnOffControl1.OperatorCodeChanged += new LogOnOffControl.OperatorCodeChangedEventHandler(logOnOffControl1_OperatorCodeChanged);
            cycleCountForm.messageBoxControl1.MessageBoxControl_ShowPrevMessage += new EventHandler<EventArgs>(messageBoxControl1_MessageBoxControl_ShowPrevMessage);
            cycleCountForm.messageBoxControl1.MessageBoxControl_ShowNextMessage += new EventHandler<EventArgs>(messageBoxControl1_MessageBoxControl_ShowNextMessage);

            // Hide form fields
            cycleCountForm.ckbxFlagBox.Visible = 
                cycleCountForm.tbxNote.Visible = cycleCountForm.lblNote.Visible = false;


            Application.Run(cycleCountForm);
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




        #region Cycle Count Combobox Methods

        public void GetCycleCountList()
        {
            string error = "";
            isDatabindingCycleCountList = true;

            var cycleCountNumbers = cycle.GetCycleCountNumbers(out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, error, "GetCycleCountList() Error");
                return;
            }
            if (cycleCountNumbers == null)
            {
                alert.ShowError(alertLevel.High, "There are no active Cycle Counts.", "GetCycleCountList() Error");
                return;
            }
            cycleCountForm.cbxCycleCount.DataSource = cycleCountNumbers;
            cycleCountForm.cbxCycleCount.DisplayMember = "Description";
            cycleCountForm.cbxCycleCount.ValueMember = "CycleCountNumber";

            SelectedCycleCount = cycleCountForm.cbxCycleCount.SelectedValue.ToString();
            cycleCountForm.pnlDataForm.Enabled = true;
            cycleCountForm.tbxLocation.Focus();

            isDatabindingCycleCountList = false;
        }

        #endregion



        #region Location Methods

        public void LocationEntered(string enteredLocation)
        {
            string err = "";

            string loc = location.ValidateLocation(enteredLocation, out err);
            if (err != "")
            {
                alert.ShowError(alertLevel.High, err, "ValidateLocation() Error");
                cycleCountForm.tbxLocation.Text = "";
                cycleCountForm.tbxLocation.Focus();
                return;
            }
            if (loc == "")
            {
                alert.ShowError(alertLevel.Medium, string.Format("Location {0} is not valid.", enteredLocation), "Error");
                cycleCountForm.tbxLocation.Text = "";
                cycleCountForm.tbxLocation.Focus();
                return;
            }
            cycleCountForm.tbxLocation.Text = loc;
            cycleCountForm.tbxSerial.Focus();
        }

        #endregion



        #region Serial Methods

        public void SerialEntered(int serial)
        {
            if (LastSerial == null)
            {
                // Prepare current serial for Cycle Count
                GetObjectInfo(serial);
            }
            else
            {
                // Add the previous serial to the Cycle Count, prepare current serial for Cycle Count
                CycleCountTheObject();
                GetObjectInfo(serial);
            }
        }

        private void GetObjectInfo(int serial)
        {
            string part, quantity, loc, error = "";

            cycle.GetObjectInfo(serial, out part, out quantity, out loc, out error);
            if (error != "")
            {
                alert.ShowError(alertLevel.High, error, "GetObjectInfo() Error");
                cycleCountForm.tbxSerial.Text = "";
                return;
            }
            LastSerial = serial;
            cycleCountForm.tbxPart.Text = part;
            cycleCountForm.tbxQuantity.Text = quantity;
            cycleCountForm.tbxRealQuantity.Focus();
        }

        public void CycleCountTheObject()
        {
            decimal realquantity = -1;
            if (cycleCountForm.tbxRealQuantity.Text.Trim() != "")
            {
                realquantity = ValidateQuantity(cycleCountForm.tbxRealQuantity.Text.Trim());
                if (realquantity < 0)
                {
                    alert.ShowError(alertLevel.Medium, "Real quantity is not valid.", "Error");
                    return;
                }
            }
            
            string error = "";
            string actionTakenMessage = "";
            int? actionTaken = null;
            string ccnumber = cycleCountForm.cbxCycleCount.SelectedValue.ToString();
            string part = cycleCountForm.tbxPart.Text;
            string loc = cycleCountForm.tbxLocation.Text.Trim();
            int lastserial = Convert.ToInt32(LastSerial);

            if (realquantity < 0)
            {
                decimal quantity = Convert.ToDecimal(cycleCountForm.tbxQuantity.Text.Trim());
                int? result = cycle.CycleCountTheObject(OperatorCode, ccnumber, lastserial, part, quantity, loc, out actionTakenMessage, out actionTaken, out error);
                if (error != "")
                {
                    alert.ShowError(alertLevel.High, error, "CycleCountTheObject() Error");
                }
                else
                {
                    messageController.ShowMessage(actionTakenMessage);
                }
            }
            else
            {
                int? result = cycle.CycleCountTheObject(OperatorCode, ccnumber, lastserial, part, realquantity, loc, out actionTakenMessage, out actionTaken, out error);
                if (error != "")
                {
                    alert.ShowError(alertLevel.High, error, "CycleCountTheObject() Error");
                }
                else
                {
                    messageController.ShowMessage(actionTakenMessage);
                }
            }
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

        private decimal ValidateQuantity(string qty)
        {
            decimal quantity = -1;
            try
            {
                quantity = Convert.ToDecimal(qty);
            }
            catch (Exception)
            {
                return quantity;
            }
            return quantity;
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
                    if (cycleCountForm.tbxLocation.Text.Trim() == "")
                    {
                        alert.ShowError(alertLevel.Medium, "Please enter a Location first.", "Error");
                        cycleCountForm.tbxSerial.Text = "";
                        cycleCountForm.tbxLocation.Focus();
                        return;
                    }
                    int serial = int.Parse(scanData.DataValue.Trim());
                    cycleCountForm.tbxSerial.Text = scanData.DataValue.Trim();
                    SerialEntered(serial);
                }
                else if (scanData.ScanDataType == eScanDataType.Location)
                {
                    cycleCountForm.tbxLocation.Text = scanData.DataValue.Trim();
                    LocationEntered(scanData.DataValue.Trim());
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

        public void ClearForm()
        {
            cycleCountForm.tbxSerial.Text = cycleCountForm.tbxPart.Text =                                                  
                cycleCountForm.tbxQuantity.Text =                                      
                cycleCountForm.tbxRealQuantity.Text =                                              
                cycleCountForm.tbxNote.Text = "";

            cycleCountForm.ckbxFlagBox.Checked = false;
        }

        public void DisplayErrorMessageFromForm(Enum alertLevel, string message)
        {
            alert.ShowError(alertLevel, message, "Message");
        }

        #endregion



    }
}
