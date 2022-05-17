using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using Newtonsoft.Json;
using AxnpcloudroomvideosdkLib;
using System.Drawing.Drawing2D;

namespace Meeting_WPF
{
    public partial class ScreenShareUI : UserControl
    {
         public AxCloudroomScreenShareUI ShareUI
        {
            get { return axScreenShareUI; }
        }

        public ScreenShareUI()
        {
            InitializeComponent();

            axScreenShareUI.keepAspectRatio = true;
            axScreenShareUI.Visible = false;// true;
            this.BackColor = Color.FromArgb(250, 250, 250);

            axScreenShareUI.Location = new Point(0,0);
            axScreenShareUI.Size = new Size(1, 1);
        }

        public void notifyScreenShareStarted()
        {
            axScreenShareUI.Visible = true;
            axScreenShareUI.SetBounds(panel_share.Bounds.X, panel_share.Bounds.Y, panel_share.Bounds.Width, panel_share.Bounds.Height);
        }

        public void startShared()
        {
            //axScreenShareUI.Visible = true;;
            axScreenShareUI.clear();
        }

        public void notifyScreenShareStopped()
        {
            axScreenShareUI.clear();
            axScreenShareUI.Visible = false;
            axScreenShareUI.Size = panel_share.Size;
        }

        public void stopShared()
        {
           
        }

    }
}
