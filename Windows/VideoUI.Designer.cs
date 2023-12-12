namespace SDKDemo
{
    partial class VideoUI
    {
        /// <summary> 
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region 组件设计器生成的代码

        /// <summary> 
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(VideoUI));
            this.label_mic = new System.Windows.Forms.Label();
            this.axCloudroomVideoUI1 = new AxnpcloudroomvideosdkLib.AxCloudroomVideoUI();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.axCloudroomVideoUI1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // label_mic
            // 
            this.label_mic.AutoSize = true;
            this.label_mic.BackColor = System.Drawing.Color.Gray;
            this.label_mic.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.label_mic.Location = new System.Drawing.Point(0, 420);
            this.label_mic.MinimumSize = new System.Drawing.Size(22, 16);
            this.label_mic.Name = "label_mic";
            this.label_mic.Size = new System.Drawing.Size(22, 16);
            this.label_mic.TabIndex = 2;
            this.label_mic.Click += new System.EventHandler(this.label_mic_Click);
            // 
            // axCloudroomVideoUI1
            // 
            this.axCloudroomVideoUI1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.axCloudroomVideoUI1.Enabled = true;
            this.axCloudroomVideoUI1.Location = new System.Drawing.Point(0, 0);
            this.axCloudroomVideoUI1.Name = "axCloudroomVideoUI1";
            this.axCloudroomVideoUI1.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axCloudroomVideoUI1.OcxState")));
            this.axCloudroomVideoUI1.Size = new System.Drawing.Size(504, 420);
            this.axCloudroomVideoUI1.TabIndex = 0;
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackColor = System.Drawing.SystemColors.ControlDarkDark;
            this.pictureBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pictureBox1.Location = new System.Drawing.Point(0, 0);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(504, 436);
            this.pictureBox1.TabIndex = 1;
            this.pictureBox1.TabStop = false;
            // 
            // VideoUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.axCloudroomVideoUI1);
            this.Controls.Add(this.label_mic);
            this.Controls.Add(this.pictureBox1);
            this.Name = "VideoUI";
            this.Size = new System.Drawing.Size(504, 436);
            ((System.ComponentModel.ISupportInitialize)(this.axCloudroomVideoUI1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Label label_mic;
        private AxnpcloudroomvideosdkLib.AxCloudroomVideoUI axCloudroomVideoUI1;


    }
}
