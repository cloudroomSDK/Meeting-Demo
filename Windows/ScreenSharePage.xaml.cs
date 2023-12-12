using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using AxnpcloudroomvideosdkLib;
using Newtonsoft.Json;
using System.Windows.Forms;
using System.ComponentModel;

namespace SDKDemo
{
    /// <summary>
    /// ScreenSharePage.xaml 的交互逻辑
    /// </summary>
    /// 

    public partial class ScreenSharePage : System.Windows.Controls.UserControl
    {
     
        private ScreenShareUI mShareUI = new ScreenShareUI();
        private bool sharingMyScreen = false;
    
        public ScreenSharePage()
        {
            InitializeComponent();
            initDeletegate(true);

            screenShareHost.Child = mShareUI;

            chkAllowControl.Visibility = Visibility.Collapsed;
            cmbMembers.Visibility = Visibility.Collapsed;
            photoBtn.Visibility = Visibility.Collapsed;
        }

        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { System.Windows.MessageBox.Show(Window.GetWindow(this), desc); }

        private void initDeletegate(bool isInit)
        {
            if (isInit)
            {
                App.CRVideo.VideoSDK.startScreenShareRslt += startScreenShareRslt;
                App.CRVideo.VideoSDK.stopScreenShareRslt += stopScreenShareRslt;
                App.CRVideo.VideoSDK.notifyScreenShareStarted += notifyScreenShareStarted;
                App.CRVideo.VideoSDK.notifyScreenShareStopped += notifyScreenShareStopped;
                App.CRVideo.VideoSDK.notifyGiveCtrlRight += notifyGiveCtrlRight;
                App.CRVideo.VideoSDK.notifyReleaseCtrlRight += notifyReleaseCtrlRight;
            }
            else
            {
                App.CRVideo.VideoSDK.startScreenShareRslt -= startScreenShareRslt;
                App.CRVideo.VideoSDK.stopScreenShareRslt -= stopScreenShareRslt;
                App.CRVideo.VideoSDK.notifyScreenShareStarted -= notifyScreenShareStarted;
                App.CRVideo.VideoSDK.notifyScreenShareStopped -= notifyScreenShareStopped;
                App.CRVideo.VideoSDK.notifyGiveCtrlRight -= notifyGiveCtrlRight;
                App.CRVideo.VideoSDK.notifyReleaseCtrlRight -= notifyReleaseCtrlRight;
            }
        }

        //对方启动屏幕共享
        private void notifyScreenShareStarted(object sender, ICloudroomVideoSDKEvents_notifyScreenShareStartedEvent e)
        {
            Console.WriteLine("notifyScreenShareStarted");

            panel_top.Visibility = Visibility.Collapsed;
            mShareUI.Visible = true;
            mShareUI.notifyScreenShareStarted();
            photoBtn.Visibility = Visibility.Visible;

        }
        //对方关闭屏幕共享
        private void notifyScreenShareStopped(object sender, EventArgs e)
        {
            panel_top.Visibility = Visibility.Visible;
            mShareUI.notifyScreenShareStopped();
            photoBtn.Visibility = Visibility.Collapsed;

        }

        public void initPage()
        {
            if (App.CRVideo.VideoSDK.isScreenShareStarted == 1) //共享已经开启
            {
                panel_top.Visibility = Visibility.Collapsed;
                mShareUI.Visible = true;
                mShareUI.notifyScreenShareStarted();
            }
            else//共享未开启
            {
                mShareUI.Visible = false;
                panel_top.Visibility = Visibility.Visible;
            }
        }

        public void stopMySharing()
        {
            if ( sharingMyScreen )
            {
                App.CRVideo.VideoSDK.stopScreenShare();
                sharingMyScreen = false;
            }
        }

        public void startScreenShareRslt(object sender, ICloudroomVideoSDKEvents_startScreenShareRsltEvent e)
        {
            if (e.p_sdkErr == (int)VCALLSDK_ERR_DEF.VCALLSDK_NOERR)
            {
                chkAllowControl.Visibility = Visibility.Visible;
                chkAllowControl.IsChecked = false;
                mShareUI.startShared();
            }
        }

        public void stopScreenShareRslt(object sender, ICloudroomVideoSDKEvents_stopScreenShareRsltEvent e)
        {
            if (e.p_sdkErr == (int)VCALLSDK_ERR_DEF.VCALLSDK_NOERR)
            {
                chkAllowControl.Visibility = Visibility.Collapsed;
                cmbMembers.Visibility = Visibility.Collapsed;

                mShareUI.stopShared();
            }
        }

        private void chkAllowControl_Click(object sender, RoutedEventArgs e)
        {
            if (chkAllowControl.IsChecked == true)
            {
                cmbMembers.IsEnabled = true;
                cmbMembers.Visibility = Visibility.Visible;
                cmbMembers.Items.Clear();
                cmbMembers.Items.Add("请选择远程控制者");

                List<MemberInfo> allMembers = JsonConvert.DeserializeObject<List<MemberInfo>>(App.CRVideo.VideoSDK.getAllMembers());
                for (int i = 0; i < allMembers.Count; i++)
                {
                    MemberInfo member = allMembers[i];
                    if (member.userID != Login.Instance.myUserID)
                    {
                        cmbMembers.Items.Add(member.userID);
                    }
                }
                if (cmbMembers.Items.Count > 0)
                {
                    cmbMembers.SelectedIndex = 0;
                }
            }
            else
            {
                //释放对方的控制权限
                if (cmbMembers.SelectedIndex > 0)
                {
                    App.CRVideo.VideoSDK.releaseCtrlRight((string)cmbMembers.SelectedItem);
                }
                cmbMembers.Visibility = Visibility.Collapsed;
            }            
        }

        private void cmbMembers_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cmbMembers.SelectedIndex <= 0)
            {
                return;
            }

            App.CRVideo.VideoSDK.giveCtrlRight((string)cmbMembers.SelectedItem);
            cmbMembers.IsEnabled = false;
        }

        private void notifyGiveCtrlRight(object sender, ICloudroomVideoSDKEvents_notifyGiveCtrlRightEvent e)
        {
            if (e.p_targetId != Login.Instance.myUserID)
                return;
            mShareUI.ShareUI.ctrlOpen = 1;
            Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "您已经获得了远程屏幕控制权限" });
        }

        private void notifyReleaseCtrlRight(object sender, ICloudroomVideoSDKEvents_notifyReleaseCtrlRightEvent e)
        {
            if (e.p_targetId != Login.Instance.myUserID)
                return;
            mShareUI.ShareUI.ctrlOpen = 0;
            Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "您的远程屏幕控制权限已经被" + e.p_operId + "回收" });
        }

        public void ContentRendered()
        {

        }

        public void unInitPage()
        {
            initDeletegate(false);

            if (mShareUI != null)
            {
                mShareUI.Dispose();
                mShareUI = null;

                GC.Collect();
            }     
        }

        private void btn_photo(object sender, RoutedEventArgs e)
        {
            string photoPath = System.Windows.Forms.Application.StartupPath + "\\Tmp\\" + System.Guid.NewGuid().ToString() + ".jpg";
            int rslt = mShareUI.ShareUI.savePic(photoPath);
            if(rslt > 0)
            {
                showImage img = new showImage();
                img.setTitle(photoPath);
                img.setImage(photoPath);
                img.Show();
            }
            else
            {
                System.Windows.MessageBox.Show("拍照失败!");
            }
        }

    }
}
