namespace SDKDemo
{
    partial class ScreenShareUI
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ScreenShareUI));
            this.panel_share = new System.Windows.Forms.Panel();
            this.axScreenShareUI = new AxnpcloudroomvideosdkLib.AxCloudroomScreenShareUI();
            this.panel_share.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.axScreenShareUI)).BeginInit();
            this.SuspendLayout();
            // 
            // panel_share
            // 
            this.panel_share.AutoScroll = true;
            this.panel_share.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("panel_share.BackgroundImage")));
            this.panel_share.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.panel_share.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel_share.Controls.Add(this.axScreenShareUI);
            this.panel_share.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel_share.Location = new System.Drawing.Point(0, 0);
            this.panel_share.Name = "panel_share";
            this.panel_share.Size = new System.Drawing.Size(696, 558);
            this.panel_share.TabIndex = 2;
            // 
            // axScreenShareUI
            // 
            this.axScreenShareUI.Dock = System.Windows.Forms.DockStyle.Fill;
            this.axScreenShareUI.Enabled = true;
            this.axScreenShareUI.Location = new System.Drawing.Point(0, 0);
            this.axScreenShareUI.Name = "axScreenShareUI";
            this.axScreenShareUI.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axScreenShareUI.OcxState")));
            this.axScreenShareUI.Size = new System.Drawing.Size(694, 556);
            this.axScreenShareUI.TabIndex = 1;
            // 
            // ScreenShareUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.panel_share);
            this.Name = "ScreenShareUI";
            this.Size = new System.Drawing.Size(696, 558);
            this.panel_share.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.axScreenShareUI)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel_share;
        private AxnpcloudroomvideosdkLib.AxCloudroomScreenShareUI axScreenShareUI;
    }
}
