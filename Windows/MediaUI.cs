using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Meeting_WPF
{
    public partial class MediaUI : UserControl
    {
        public MediaUI()
        {
            InitializeComponent();
            string mediaCfg = "{\"size\":\"864*480\", \"fps\":25}";
            App.CRVideo.VideoSDK.setMediaCfg(mediaCfg);
            this.axCloudroomMediaUI1.keepAspectRatio = true;
        }

        public void startPlayMedia(string url)
        {
            App.CRVideo.VideoSDK.startPlayMedia(url, 0, 0);
        }

        public void stopPlayMedia()
        {
            App.CRVideo.VideoSDK.stopPlayMedia();
        }

        public void disableToolBar(bool bDis)
        {
            this.axCloudroomMediaUI1.disableToolBar(Convert.ToInt16(bDis));
        }
    }
}
