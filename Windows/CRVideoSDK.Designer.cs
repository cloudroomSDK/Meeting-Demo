namespace Meeting_WPF
{
    partial class CRVideoSDK
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(CRVideoSDK));
            this.axCRVideo = new AxnpcloudroomvideosdkLib.AxCloudroomVideoSDK();
            ((System.ComponentModel.ISupportInitialize)(this.axCRVideo)).BeginInit();
            this.SuspendLayout();
            // 
            // axCRVideo
            // 
            this.axCRVideo.Enabled = true;
            this.axCRVideo.Location = new System.Drawing.Point(80, 69);
            this.axCRVideo.Name = "axCRVideo";
            this.axCRVideo.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axCRVideo.OcxState")));
            this.axCRVideo.Size = new System.Drawing.Size(75, 23);
            this.axCRVideo.TabIndex = 3;
            // 
            // CRVideoSDK
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.axCRVideo);
            this.Name = "CRVideoSDK";
            this.Size = new System.Drawing.Size(182, 129);
            ((System.ComponentModel.ISupportInitialize)(this.axCRVideo)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private AxnpcloudroomvideosdkLib.AxCloudroomVideoSDK axCRVideo;

    }
}
