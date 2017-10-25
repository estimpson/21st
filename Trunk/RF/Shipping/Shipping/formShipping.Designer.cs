using Controls;

namespace Shipping
{
    partial class formShipping
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
            this.menuItemClose = new System.Windows.Forms.MenuItem();
            this.menuItemRefresh = new System.Windows.Forms.MenuItem();
            this.logOnOffControl1 = new Controls.LogOnOffControl();
            this.messageBoxControl1 = new Controls.MessageBoxControl();
            this.label1 = new System.Windows.Forms.Label();
            this.cbxShippers = new System.Windows.Forms.ComboBox();
            this.btnPickShipper = new System.Windows.Forms.Button();
            this.gridLines = new System.Windows.Forms.DataGrid();
            this.gridObjects = new System.Windows.Forms.DataGrid();
            this.label2 = new System.Windows.Forms.Label();
            this.cbxSerials = new System.Windows.Forms.ComboBox();
            this.btnStageUnstage = new System.Windows.Forms.Button();
            this.pnlMain = new System.Windows.Forms.Panel();
            this.pnlMain.SuspendLayout();
            this.SuspendLayout();
            // 
            // mainMenu1
            // 
            this.mainMenu1.MenuItems.Add(this.menuItemClose);
            this.mainMenu1.MenuItems.Add(this.menuItemRefresh);
            // 
            // menuItemClose
            // 
            this.menuItemClose.Text = "Close";
            this.menuItemClose.Click += new System.EventHandler(this.menuItemClose_Click);
            // 
            // menuItemRefresh
            // 
            this.menuItemRefresh.Text = "Refresh";
            this.menuItemRefresh.Click += new System.EventHandler(this.menuItemRefresh_Click);
            // 
            // logOnOffControl1
            // 
            this.logOnOffControl1.Location = new System.Drawing.Point(0, 0);
            this.logOnOffControl1.Name = "logOnOffControl1";
            this.logOnOffControl1.Size = new System.Drawing.Size(240, 29);
            this.logOnOffControl1.TabIndex = 0;
            // 
            // messageBoxControl1
            // 
            this.messageBoxControl1.Location = new System.Drawing.Point(0, 214);
            this.messageBoxControl1.Name = "messageBoxControl1";
            this.messageBoxControl1.Size = new System.Drawing.Size(240, 54);
            this.messageBoxControl1.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(5, 6);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(66, 20);
            this.label1.Text = "ShipperID";
            // 
            // cbxShippers
            // 
            this.cbxShippers.Location = new System.Drawing.Point(65, 2);
            this.cbxShippers.Name = "cbxShippers";
            this.cbxShippers.Size = new System.Drawing.Size(110, 22);
            this.cbxShippers.TabIndex = 3;
            this.cbxShippers.SelectedIndexChanged += new System.EventHandler(this.cbxShippers_SelectedIndexChanged);
            // 
            // btnPickShipper
            // 
            this.btnPickShipper.BackColor = System.Drawing.Color.White;
            this.btnPickShipper.Location = new System.Drawing.Point(181, 3);
            this.btnPickShipper.Name = "btnPickShipper";
            this.btnPickShipper.Size = new System.Drawing.Size(54, 20);
            this.btnPickShipper.TabIndex = 4;
            this.btnPickShipper.Text = "Pick";
            this.btnPickShipper.Click += new System.EventHandler(this.btnPickShipper_Click);
            // 
            // gridLines
            // 
            this.gridLines.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(128)))), ((int)(((byte)(128)))));
            this.gridLines.Location = new System.Drawing.Point(3, 26);
            this.gridLines.Name = "gridLines";
            this.gridLines.Size = new System.Drawing.Size(234, 57);
            this.gridLines.TabIndex = 5;
            // 
            // gridObjects
            // 
            this.gridObjects.BackgroundColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(128)))), ((int)(((byte)(128)))));
            this.gridObjects.Location = new System.Drawing.Point(3, 114);
            this.gridObjects.Name = "gridObjects";
            this.gridObjects.Size = new System.Drawing.Size(234, 65);
            this.gridObjects.TabIndex = 6;
            // 
            // label2
            // 
            this.label2.Location = new System.Drawing.Point(28, 89);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(37, 20);
            this.label2.Text = "Serial";
            // 
            // cbxSerials
            // 
            this.cbxSerials.Location = new System.Drawing.Point(65, 86);
            this.cbxSerials.Name = "cbxSerials";
            this.cbxSerials.Size = new System.Drawing.Size(110, 22);
            this.cbxSerials.TabIndex = 8;
            this.cbxSerials.SelectedIndexChanged += new System.EventHandler(this.cbxSerials_SelectedIndexChanged);
            // 
            // btnStageUnstage
            // 
            this.btnStageUnstage.BackColor = System.Drawing.Color.White;
            this.btnStageUnstage.Location = new System.Drawing.Point(181, 87);
            this.btnStageUnstage.Name = "btnStageUnstage";
            this.btnStageUnstage.Size = new System.Drawing.Size(54, 20);
            this.btnStageUnstage.TabIndex = 9;
            this.btnStageUnstage.Text = "Stage";
            this.btnStageUnstage.Click += new System.EventHandler(this.btnStageUnstage_Click);
            // 
            // pnlMain
            // 
            this.pnlMain.BackColor = System.Drawing.Color.Gainsboro;
            this.pnlMain.Controls.Add(this.gridObjects);
            this.pnlMain.Controls.Add(this.btnPickShipper);
            this.pnlMain.Controls.Add(this.cbxSerials);
            this.pnlMain.Controls.Add(this.cbxShippers);
            this.pnlMain.Controls.Add(this.btnStageUnstage);
            this.pnlMain.Controls.Add(this.label2);
            this.pnlMain.Controls.Add(this.gridLines);
            this.pnlMain.Controls.Add(this.label1);
            this.pnlMain.Location = new System.Drawing.Point(0, 29);
            this.pnlMain.Name = "pnlMain";
            this.pnlMain.Size = new System.Drawing.Size(240, 186);
            // 
            // formShipping
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.AutoScroll = true;
            this.ClientSize = new System.Drawing.Size(240, 268);
            this.Controls.Add(this.pnlMain);
            this.Controls.Add(this.messageBoxControl1);
            this.Controls.Add(this.logOnOffControl1);
            this.Menu = this.mainMenu1;
            this.Name = "formShipping";
            this.Text = "Shipping";
            this.pnlMain.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.MenuItem menuItemClose;
        private System.Windows.Forms.MenuItem menuItemRefresh;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        public System.Windows.Forms.Panel pnlMain;
        public System.Windows.Forms.ComboBox cbxShippers;
        public System.Windows.Forms.Button btnPickShipper;
        public ScrollableGrid gridLines;
        public System.Windows.Forms.DataGrid gridObjects;
        public System.Windows.Forms.ComboBox cbxSerials;
        public System.Windows.Forms.Button btnStageUnstage;
        public Controls.LogOnOffControl logOnOffControl1;
        public Controls.MessageBoxControl messageBoxControl1;
    }
}

