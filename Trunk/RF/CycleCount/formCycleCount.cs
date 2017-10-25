using System;
using System.Windows.Forms;
using Connection;
using Controls;
using SymbolRFGun;

namespace CycleCount
{
    public partial class formCycleCount : Form
    {
        private Controller controller;

        enum alertLevel
        {
            Medium,
            High
        }

        public formCycleCount(Controller con)
        {
            InitializeComponent();

            InitializeScanning();

            controller = con;
        }


        ~formCycleCount()
        {
#if PocketPC
            if (FXRFGlobals.MyRFGun != null)
            {
                FXRFGlobals.MyRFGun.StopRead();
                FXRFGlobals.MyRFGun.RFScan -= _RFScanEventHandler;
                FXRFGlobals.MyRFGun.Close();
            }
#endif
        }




        #region RFScanner
#if PocketPC
        private RFScanEventHandler _RFScanEventHandler;
#endif

        private void InitializeScanning()
        {
#if PocketPC
            _RFScanEventHandler = new RFScanEventHandler(MyRFGun_RFScan);
            FXRFGlobals.MyRFGun.RFScan += _RFScanEventHandler;
#endif
        }


        void MyRFGun_RFScan(object sender, RFScanEventArgs e)
        {
            controller.handleScan(e);
        }


//        private void formFXMES_Closing(object sender, CancelEventArgs e)
//        {
//#if PocketPC
//            if (FXRFGlobals.MyRFGun != null)
//            {
//                FXRFGlobals.MyRFGun.StopRead();
//                FXRFGlobals.MyRFGun.RFScan -= _RFScanEventHandler;
//                FXRFGlobals.MyRFGun.Close();
//            }
//#endif
//        }
        #endregion



            
        #region Menu Items

        private void menuItemClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void menuItemRefresh_Click(object sender, EventArgs e)
        {
            controller.RefreshScreen();
        }

        #endregion




        #region Location

        private void btnLocationEnter_Click(object sender, EventArgs e)
        {
            if (tbxLocation.Text.Trim() == "")
            {
                controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a Location.");  
                tbxLocation.Focus();
                return;
            }
            // Validate location
            controller.LocationEntered(tbxLocation.Text.Trim());
        }

        private void tbxLocation_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                if (tbxLocation.Text.Trim() == "")
                {
                    controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a Location.");
                    tbxLocation.Focus();
                    return;
                }
                // Validate location
                controller.LocationEntered(tbxLocation.Text.Trim());
            }
        }

        #endregion



        #region Serial

        private void btnSerialEnter_Click(object sender, EventArgs e)
        {
            if (tbxLocation.Text.Trim() == "")
            {
                controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a Location first.");
                tbxSerial.Text = "";
                tbxLocation.Focus();
                return;
            }
            if (tbxSerial.Text.Trim() == "")
            {
                controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a serial number.");
                tbxSerial.Focus();
                return;
            }
            int serial = controller.ValidateSerial(tbxSerial.Text.Trim());
            if (serial == 0)
            {
                controller.DisplayErrorMessageFromForm(alertLevel.Medium, string.Format("{0} is not a valid serial number.", tbxSerial.Text));
                tbxSerial.Text = "";
                tbxSerial.Focus();
                return;
            }
            // Process serial
            controller.SerialEntered(serial);
        }

        private void tbxSerial_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)13)
            {
                if (tbxLocation.Text.Trim() == "")
                {
                    controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a Location first.");
                    tbxSerial.Text = "";
                    tbxLocation.Focus();
                    return;
                }
                if (tbxSerial.Text.Trim() == "")
                {
                    controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a serial number.");
                    tbxSerial.Focus();
                    return;
                }
                int serial = controller.ValidateSerial(tbxSerial.Text.Trim());
                if (serial == 0)
                {
                    controller.DisplayErrorMessageFromForm(alertLevel.Medium, string.Format("{0} is not a valid serial number.", tbxSerial.Text));
                    tbxSerial.Text = "";
                    tbxSerial.Focus();
                    return;
                }
                // Process serial
                controller.SerialEntered(serial);
            }
        }

        #endregion


        #region Other Form Controls

        private void cbxCycleCount_SelectedIndexChanged(object sender, EventArgs e)
        {
            controller.SelectedCycleCount = cbxCycleCount.SelectedText;
        }

        private void ckbxFlagBox_CheckStateChanged(object sender, EventArgs e)
        {
            controller.IsBoxFlagged = ckbxFlagBox.Checked;
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            if (tbxLocation.Text.Trim() == "")
            {
                controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a Location first.");
                tbxSerial.Text = "";
                tbxLocation.Focus();
                return;
            }
            if (tbxSerial.Text.Trim() == "")
            {
                controller.DisplayErrorMessageFromForm(alertLevel.Medium, "Please enter a serial number.");
                tbxSerial.Focus();
                return;
            }
            controller.CycleCountTheObject();
            controller.LastSerial = null;
            controller.ClearForm();

            tbxSerial.Focus();
        }

        #endregion




    }
}