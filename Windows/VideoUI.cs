using System.Windows.Forms;
using System.Drawing;
using System.IO;
using System;
using System.Collections.Generic;
using AxnpcloudroomvideosdkLib;

namespace SDKDemo
{
    public partial class VideoUI : UserControl
    {
        private string mUserID = "";
        private int mVideoID = 0;
        private Int64 lastFrmTime = 0;

        public VideoUI()
        {
            InitializeComponent();

            axCloudroomVideoUI1.keepAspectRatio = true;
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox1.Visible = false;

            label_mic.BringToFront();
            label_mic.Size = new Size(22, 16);
            label_mic.Image = SDKDemo.Properties.Resources.mic_closed;
            label_mic.Visible = false;
            label_mic.ImageAlign = ContentAlignment.MiddleCenter;

            axCloudroomVideoUI1.notifyFullScreenChange += notifyFullScreenChange;
        }

        private bool mBigStream;
       
        public string userID
        {
            get { return mUserID; }
        }

        public int videoID
        {
            get { return mVideoID; }
        }

        public void setVideo(string userID, int videoID, bool bBigStream = false)
        {
            mUserID = userID;
            mVideoID = videoID;
            lastFrmTime = 0;
            mBigStream = bBigStream;
            axCloudroomVideoUI1.setVideo(userID, videoID);            
            updateMicStatus(App.CRVideo.VideoSDK.getAudioStatus(userID));
        }

        public void setVideo2(string userID, int videoID, int quality, bool bBigStream = false)
        {
            mUserID = userID;
            mVideoID = videoID;
            lastFrmTime = 0;
            mBigStream = bBigStream;

            axCloudroomVideoUI1.setVideo2(userID, videoID, quality);
            updateMicStatus(App.CRVideo.VideoSDK.getAudioStatus(userID));
        }

        public void clear()
        {
            axCloudroomVideoUI1.clear();
            pictureBox1.Image = null;
            label_mic.Visible = false;
        }

        private class VideoImgObj
        {
            public int format = 0;
        }                

        public void updateImg(Int64 picFrame)
        {
            try 
            {
                if (picFrame <= lastFrmTime)
                    return;

                Array array = axCloudroomVideoUI1.savePicToArray("bmp");
                if (array.Length == 0)
                    return;

                lastFrmTime = axCloudroomVideoUI1.getPicFrameTime();
                byte[] imgBytes = (byte[])array;
                using (MemoryStream newPhoto = new MemoryStream(imgBytes))
                {
                    Bitmap img = new Bitmap(newPhoto);
                    pictureBox1.Image = img;
                }
                GC.Collect();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }       
        }

        public void updateMicStatus(string userID, int status)
        {
            if (userID != mUserID)
                return;

            updateMicStatus(status);
        }
            
        public void updateMicEnergy(string userID, int level)
        {
            if (userID != mUserID)
                return;

            int status = App.CRVideo.VideoSDK.getAudioStatus(userID);
            if (status == (int)ASTATUS.ACLOSE)
            {
                label_mic.Image = SDKDemo.Properties.Resources.mic_closed;
                return;
            }

            if (level == 0)
                label_mic.Image = SDKDemo.Properties.Resources.mic_0;
            else if (level <= 3)
                label_mic.Image = SDKDemo.Properties.Resources.mic_1;
            else if (level <= 6)
                label_mic.Image = SDKDemo.Properties.Resources.mic_2;
            else
                label_mic.Image = SDKDemo.Properties.Resources.mic_3;
        
        }

        public void updateMicStatus(int newStatus)
        {
            if (userID == "")
                return;

            label_mic.Visible = true;

            if (newStatus == (int)ASTATUS.ACLOSE)
            {
                label_mic.Image = SDKDemo.Properties.Resources.mic_closed;   
            }
            else if (newStatus == (int)ASTATUS.AOPEN || newStatus == (int)ASTATUS.AOPENING)
            {
                label_mic.Image = SDKDemo.Properties.Resources.mic_0;
            }        
            else
            {
                label_mic.Visible = false;
            }
        }
        private void label_mic_Click(object sender, EventArgs e)
        {
            int micStatus = App.CRVideo.VideoSDK.getAudioStatus(mUserID);
            if (micStatus <= (int)ASTATUS.ACLOSE)
            {
                App.CRVideo.VideoSDK.openMic(mUserID);
            }
            else
            {
                App.CRVideo.VideoSDK.closeMic(mUserID);               
            }
        }
        private void notifyFullScreenChange(object sender, ICloudroomVideoUIEvents_notifyFullScreenChangeEvent e)
        {
            if (mUserID == Login.Instance.myUserID || mBigStream || mVideoID <= 0)
                return;

            if (e.p_fullScreen)
            {
                setVideo(mUserID, mVideoID);
            }
            else
            {
                setVideo2(mUserID, mVideoID, 2);
            }
        }

    }
}
