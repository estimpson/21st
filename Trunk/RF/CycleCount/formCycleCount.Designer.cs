namespace CycleCount
{
    partial class formCycleCount
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;
        private System.Windows.Forms.MainMenu mainMenu1;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.mainMenu1 = new System.Windows.Forms.MainMenu();
            this.menuItem1 = new System.Windows.Forms.MenuItem();
            this.menuItem2 = new System.Windows.Forms.MenuItem();
            this.logOnOffControl1 = new Controls.LogOnOffControl();
            this.messageBoxControl1 = new Controls.MessageBoxControl();
            this.pnlMain = new System.Windows.Forms.Panel();
            this.pnlDataForm = new System.Windows.Forms.Panel();
            this.tbxSerial = new System.Windows.Forms.TextBox();
            this.btnSave = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.tbxNote = new System.Windows.Forms.TextBox();
            this.tbxPart = new System.Windows.Forms.TextBox();
            this.ckbxFlagBox = new System.Windows.Forms.CheckBox();
            this.lblNote = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.tbxQuantity = new System.Windows.Forms.TextBox();
            this.tbxLocation = new System.Windows.Forms.TextBox();
            this.tbxRealQuantity = new System.Windows.Forms.TextBox();
            this.btnLocationEnter = new System.Windows.Forms.Button();
            this.btnSerialEnter = new System.Windows.Forms.Button();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.cbxCycleCount = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.pnlMain.SuspendLayout();
            this.pnlDataForm.SuspendLayout();
            this.SuspendLayout();
            // 
            // mainMenu1
            // 
            this.mainMenu1.MenuItems.Add(this.menuItem1);
            this.mainMenu1.MenuItems.Add(this.menuItem2);
            // 
            // menuItem1
            // 
            this.menuItem1.Text = "Close";
            this.menuItem1.Click += new System.EventHandler(this.menuItemClose_Click);
            // 
            // menuItem2
            // 
            this.menuItem2.Text = "Refresh";
            this.menuItem2.Click += new System.EventHandler(this.menuItemRefresh_Click);
            // 
            // logOnOffControl1
            // 
            this.logOnOffControl1.Location = new System.Drawing.Point(0, 0);
            this.logOnOffControl1.Name = "logOnOffControl1";
            this.logOnOffControl1.Size = new System.Drawing.Size(240, 29);
            this.logOnOffControl1.TabIndex = 2;
            // 
            // messageBoxControl1
            // 
            this.messageBoxControl1.Location = new System.Drawing.Point(0, 214);
            this.messageBoxControl1.Name = "messageBoxControl1";
            this.messageBoxControl1.Size = new System.Drawing.Size(240, 54);
            this.messageBoxControl1.TabIndex = 1;
            // 
            // pnlMain
            // 
            this.pnlMain.BackColor = System.Drawing.Color.LightSteelBlue;
            this.pnlMain.Controls.Add(this.pnlDataForm);
            this.pnlMain.Controls.Add(this.cbxCycleCount);
            this.pnlMain.Controls.Add(this.label1);
            this.pnlMain.Location = new System.Drawing.Point(0, 29);
            this.pnlMain.Name = "pnlMain";
            this.pnlMain.Size = new System.Drawing.Size(240, 185);
            // 
            // pnlDataForm
            // 
            this.pnlDataForm.BackColor = System.Drawing.Color.LightSteelBlue;
            this.pnlDataForm.Controls.Add(this.tbxSerial);
            this.pnlDataForm.Controls.Add(this.btnSave);
            this.pnlDataForm.Controls.Add(this.label2);
            this.pnlDataForm.Controls.Add(this.tbxNote);
            this.pnlDataForm.Controls.Add(this.tbxPart);
            this.pnlDataForm.Controls.Add(this.ckbxFlagBox);
            this.pnlDataForm.Controls.Add(this.lblNote);
            this.pnlDataForm.Controls.Add(this.label3);
            this.pnlDataForm.Controls.Add(this.tbxQuantity);
            this.pnlDataForm.Controls.Add(this.tbxLocation);
            this.pnlDataForm.Controls.Add(this.tbxRealQuantity);
            this.pnlDataForm.Controls.Add(this.btnLocationEnter);
            this.pnlDataForm.Controls.Add(this.btnSerialEnter);
            this.pnlDataForm.Controls.Add(this.label6);
            this.pnlDataForm.Controls.Add(this.label5);
            this.pnlDataForm.Controls.Add(this.label4);
            this.pnlDataForm.Location = new System.Drawing.Point(5, 31);
            this.pnlDataForm.Name = "pnlDataForm";
            this.pnlDataForm.Size = new System.Drawing.Size(232, 151);
            // 
            // tbxSerial
            // 
            this.tbxSerial.Location = new System.Drawing.Point(62, 27);
            this.tbxSerial.Name = "tbxSerial";
            this.tbxSerial.Size = new System.Drawing.Size(101, 21);
            this.tbxSerial.TabIndex = 5;
            this.tbxSerial.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.tbxSerial_KeyPress);
            // 
            // btnSave
            // 
            this.btnSave.BackColor = System.Drawing.Color.YellowGreen;
            this.btnSave.Location = new System.Drawing.Point(168, 108);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(60, 40);
            this.btnSave.TabIndex = 24;
            this.btnSave.Text = "Save";
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // label2
            // 
            this.label2.Location = new System.Drawing.Point(4, 5);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(57, 20);
            this.label2.Text = "Location:";
            // 
            // tbxNote
            // 
            this.tbxNote.Location = new System.Drawing.Point(37, 119);
            this.tbxNote.Multiline = true;
            this.tbxNote.Name = "tbxNote";
            this.tbxNote.Size = new System.Drawing.Size(127, 30);
            this.tbxNote.TabIndex = 12;
            // 
            // tbxPart
            // 
            this.tbxPart.Location = new System.Drawing.Point(62, 51);
            this.tbxPart.Name = "tbxPart";
            this.tbxPart.ReadOnly = true;
            this.tbxPart.Size = new System.Drawing.Size(101, 21);
            this.tbxPart.TabIndex = 16;
            // 
            // ckbxFlagBox
            // 
            this.ckbxFlagBox.Location = new System.Drawing.Point(37, 98);
            this.ckbxFlagBox.Name = "ckbxFlagBox";
            this.ckbxFlagBox.Size = new System.Drawing.Size(100, 20);
            this.ckbxFlagBox.TabIndex = 11;
            this.ckbxFlagBox.Text = "Flag this box";
            this.ckbxFlagBox.CheckStateChanged += new System.EventHandler(this.ckbxFlagBox_CheckStateChanged);
            // 
            // lblNote
            // 
            this.lblNote.Location = new System.Drawing.Point(3, 118);
            this.lblNote.Name = "lblNote";
            this.lblNote.Size = new System.Drawing.Size(38, 20);
            this.lblNote.Text = "Note:";
            // 
            // label3
            // 
            this.label3.Location = new System.Drawing.Point(21, 28);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(46, 20);
            this.label3.Text = "Serial:";
            // 
            // tbxQuantity
            // 
            this.tbxQuantity.Location = new System.Drawing.Point(62, 75);
            this.tbxQuantity.Name = "tbxQuantity";
            this.tbxQuantity.ReadOnly = true;
            this.tbxQuantity.Size = new System.Drawing.Size(54, 21);
            this.tbxQuantity.TabIndex = 15;
            // 
            // tbxLocation
            // 
            this.tbxLocation.Location = new System.Drawing.Point(63, 3);
            this.tbxLocation.Name = "tbxLocation";
            this.tbxLocation.Size = new System.Drawing.Size(100, 21);
            this.tbxLocation.TabIndex = 4;
            this.tbxLocation.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.tbxLocation_KeyPress);
            // 
            // tbxRealQuantity
            // 
            this.tbxRealQuantity.Location = new System.Drawing.Point(173, 75);
            this.tbxRealQuantity.Name = "tbxRealQuantity";
            this.tbxRealQuantity.Size = new System.Drawing.Size(54, 21);
            this.tbxRealQuantity.TabIndex = 14;
            // 
            // btnLocationEnter
            // 
            this.btnLocationEnter.BackColor = System.Drawing.Color.White;
            this.btnLocationEnter.Location = new System.Drawing.Point(168, 4);
            this.btnLocationEnter.Name = "btnLocationEnter";
            this.btnLocationEnter.Size = new System.Drawing.Size(60, 20);
            this.btnLocationEnter.TabIndex = 6;
            this.btnLocationEnter.Text = "Enter";
            this.btnLocationEnter.Click += new System.EventHandler(this.btnLocationEnter_Click);
            // 
            // btnSerialEnter
            // 
            this.btnSerialEnter.BackColor = System.Drawing.Color.White;
            this.btnSerialEnter.Location = new System.Drawing.Point(168, 28);
            this.btnSerialEnter.Name = "btnSerialEnter";
            this.btnSerialEnter.Size = new System.Drawing.Size(60, 20);
            this.btnSerialEnter.TabIndex = 7;
            this.btnSerialEnter.Text = "Enter";
            this.btnSerialEnter.Click += new System.EventHandler(this.btnSerialEnter_Click);
            // 
            // label6
            // 
            this.label6.Location = new System.Drawing.Point(118, 78);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(63, 20);
            this.label6.Text = "Real Qty:";
            // 
            // label5
            // 
            this.label5.Location = new System.Drawing.Point(33, 78);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(36, 20);
            this.label5.Text = "Qty:";
            // 
            // label4
            // 
            this.label4.Location = new System.Drawing.Point(30, 52);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(40, 20);
            this.label4.Text = "Part:";
            // 
            // cbxCycleCount
            // 
            this.cbxCycleCount.Location = new System.Drawing.Point(42, 6);
            this.cbxCycleCount.Name = "cbxCycleCount";
            this.cbxCycleCount.Size = new System.Drawing.Size(190, 22);
            this.cbxCycleCount.TabIndex = 0;
            this.cbxCycleCount.SelectedIndexChanged += new System.EventHandler(this.cbxCycleCount_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(5, 8);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(70, 20);
            this.label1.Text = "Cycle:";
            // 
            // formCycleCount
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.AutoScroll = true;
            this.ClientSize = new System.Drawing.Size(240, 268);
            this.Controls.Add(this.pnlMain);
            this.Controls.Add(this.messageBoxControl1);
            this.Controls.Add(this.logOnOffControl1);
            this.Menu = this.mainMenu1;
            this.Name = "formCycleCount";
            this.Text = "Cycle Count 1.3";
            this.pnlMain.ResumeLayout(false);
            this.pnlDataForm.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.MenuItem menuItem1;
        private System.Windows.Forms.MenuItem menuItem2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label4;
        public System.Windows.Forms.Button btnSerialEnter;
        public System.Windows.Forms.Button btnLocationEnter;
        public System.Windows.Forms.TextBox tbxSerial;
        public System.Windows.Forms.TextBox tbxLocation;
        public System.Windows.Forms.ComboBox cbxCycleCount;
        public System.Windows.Forms.TextBox tbxNote;
        public System.Windows.Forms.CheckBox ckbxFlagBox;
        public System.Windows.Forms.TextBox tbxPart;
        public System.Windows.Forms.TextBox tbxQuantity;
        public System.Windows.Forms.TextBox tbxRealQuantity;
        public System.Windows.Forms.Panel pnlMain;
        public Controls.LogOnOffControl logOnOffControl1;
        public Controls.MessageBoxControl messageBoxControl1;
        public System.Windows.Forms.Button btnSave;
        public System.Windows.Forms.Panel pnlDataForm;
        public System.Windows.Forms.Label lblNote;
    }
}

