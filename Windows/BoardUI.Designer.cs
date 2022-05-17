namespace Meeting_WPF
{
    partial class BoardUI
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(BoardUI));
            this.axCloudroomBoardUI1 = new AxnpcloudroomvideosdkLib.AxCloudroomBoardUI();
            ((System.ComponentModel.ISupportInitialize)(this.axCloudroomBoardUI1)).BeginInit();
            this.SuspendLayout();
            // 
            // axCloudroomBoardUI1
            // 
            this.axCloudroomBoardUI1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.axCloudroomBoardUI1.Enabled = true;
            this.axCloudroomBoardUI1.Location = new System.Drawing.Point(0, 0);
            this.axCloudroomBoardUI1.Name = "axCloudroomBoardUI1";
            this.axCloudroomBoardUI1.OcxState = ((System.Windows.Forms.AxHost.State)(resources.GetObject("axCloudroomBoardUI1.OcxState")));
            this.axCloudroomBoardUI1.Size = new System.Drawing.Size(749, 720);
            this.axCloudroomBoardUI1.TabIndex = 0;
            // 
            // BoardUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.axCloudroomBoardUI1);
            this.Name = "BoardUI";
            this.Size = new System.Drawing.Size(749, 720);
            ((System.ComponentModel.ISupportInitialize)(this.axCloudroomBoardUI1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private AxnpcloudroomvideosdkLib.AxCloudroomBoardUI axCloudroomBoardUI1;

    }
}
