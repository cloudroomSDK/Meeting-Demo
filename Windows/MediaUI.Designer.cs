namespace Meeting_WPF
{
    partial class MediaUI
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MediaUI));
            this.axCloudroomMediaUI1 = new AxnpcloudroomvideosdkLib.AxCloudroomMediaUI();
            ((System.ComponentModel.ISupportInitialize)(this.axCloudroomMediaUI1)).BeginInit();
            this.SuspendLayout();
            // 
            // axCloudroomMediaUI1
            // 
            this.axCloudroomMediaUI1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.axCloudroomMediaUI1.Enabled = true;
            this.axCloudroomMediaUI1.Location = new System.Drawing.Point(0, 0);
            this.axCloudroomMediaUI1.Name = "axCloudroomMediaUI1";
            this.axCloudroomMediaUI1.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axCloudroomMediaUI1.OcxState")));
            this.axCloudroomMediaUI1.Size = new System.Drawing.Size(426, 224);
            this.axCloudroomMediaUI1.TabIndex = 0;
            // 
            // MediaUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.axCloudroomMediaUI1);
            this.Name = "MediaUI";
            this.Size = new System.Drawing.Size(426, 224);
            ((System.ComponentModel.ISupportInitialize)(this.axCloudroomMediaUI1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private AxnpcloudroomvideosdkLib.AxCloudroomMediaUI axCloudroomMediaUI1;
    }
}
