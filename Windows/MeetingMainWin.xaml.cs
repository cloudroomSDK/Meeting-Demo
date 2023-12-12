using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Data;
using System.Windows.Media.Imaging;
using AxnpcloudroomvideosdkLib;
using Newtonsoft.Json;
using System.Windows.Forms;

namespace SDKDemo
{
    /// <summary>
    /// MeetingMainWin.xaml 的交互逻辑
    /// </summary>
    public partial class MeetingMainWin : Window
    {
        private VideoWallLayoutChangeEvent mLayoutChangedEvent = new VideoWallLayoutChangeEvent();
        private DevicesSetWin mDevicesSet = null;
        private VideoWallPage mVideoWall = null;
        private ScreenSharePage mScreen = null;
        private RecordWin mRecord = null;
        private MediaSharePage mMediaShare = null;
        private Invite mInvite = null;


        //定义视频分屏数变化和视频比例的通知委托
        public delegate void VideoWallLayoutChangeEventHandler();
        public delegate void VideoUIRationChangeEventHandler();
        public delegate void VideoContentChangeEventHandler();

        public class VideoUI
        {
            public string userID;
            public int camID;
            public VideoUI(string user, int cam)
            {
                userID = user;
                camID = cam;
            }
        }
        //分屏数变化事件
        public class VideoWallLayoutChangeEvent
        {
            public List<VideoUI> videoUIs = new List<VideoUI>();
            public int layoutCount = 0;
            public float videoRation = 16F / 9F;

            public event VideoWallLayoutChangeEventHandler LayoutChanged;
            public event VideoUIRationChangeEventHandler VideoRationChanged;
            public event VideoContentChangeEventHandler VideoContentChanged;

            public void OnLayoutChanged()
            {
                if (LayoutChanged != null)
                {
                    LayoutChanged();
                }
            }

            public void OnContentChanged()
            {
                if (VideoContentChanged != null)
                {
                    VideoContentChanged();
                }
            }

            public void OnVideoRationChanged()
            {
                if (VideoRationChanged != null)
                {
                    VideoRationChanged();
                }
            }
        }        

        public MeetingMainWin(Window parent)
        {
            InitializeComponent();
            this.Owner = parent;
            this.Owner.ShowInTaskbar = false;

            initDelegate(true);          

            //创建主功能子窗体：视频墙、屏幕共享、电子白板、IM
            mVideoWall = new VideoWallPage(mLayoutChangedEvent);
            mVideoWall.Visibility = Visibility.Collapsed;
            MainPanel.Children.Add(mVideoWall);

            mScreen = new ScreenSharePage();
            mScreen.Visibility = Visibility.Collapsed;
            MainPanel.Children.Add(mScreen);

            mRecord = new RecordWin(mLayoutChangedEvent); 

            mMediaShare = new MediaSharePage();
            mMediaShare.Visibility = Visibility.Collapsed;
            MainPanel.Children.Add(mMediaShare);

            mDevicesSet = new DevicesSetWin(mLayoutChangedEvent);
            mDevicesSet.initDevs();
            mDevicesSet.initSetting();
        }

        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { System.Windows.MessageBox.Show(this, desc); }

        private void initDelegate( bool isInit)
        {
            if (isInit)
            {
                App.CRVideo.VideoSDK.startScreenShareRslt += startScreenShareRslt;
                App.CRVideo.VideoSDK.stopScreenShareRslt += stopScreenShareRslt;
                App.CRVideo.VideoSDK.notifyScreenShareStarted += notifyScreenShareStarted;
                App.CRVideo.VideoSDK.notifyScreenShareStopped += notifyScreenShareStopped;
                App.CRVideo.VideoSDK.notifyMediaStart += notifyMediaStart;
                App.CRVideo.VideoSDK.notifyMediaStop += notifyMediaStop;
                App.CRVideo.VideoSDK.audioDevChanged += audioDevChanged;
                App.CRVideo.VideoSDK.videoDevChanged += videoDevChanged;
                App.CRVideo.VideoSDK.setDNDStatusFail += setDNDStatusFail;
                App.CRVideo.VideoSDK.setDNDStatusSuccess += setDNDStatusSuccess;
                App.CRVideo.VideoSDK.netStateChanged += netStateChanged;
                App.CRVideo.VideoSDK.userEnterMeeting += userEnterMeeting;
                App.CRVideo.VideoSDK.userLeftMeeting += userLeftMeeting;
                App.CRVideo.VideoSDK.notifyAllAudioClose += notifyAllAudioClose;
                App.CRVideo.VideoSDK.audioStatusChanged += audioStatusChanged;
                App.CRVideo.VideoSDK.videoStatusChanged += videoStatusChanged;
                App.CRVideo.VideoSDK.micEnergyUpdate += micEnergyUpdate;

            }
            else
            {
                App.CRVideo.VideoSDK.startScreenShareRslt -= startScreenShareRslt;
                App.CRVideo.VideoSDK.stopScreenShareRslt -= stopScreenShareRslt;
                App.CRVideo.VideoSDK.notifyScreenShareStarted -= notifyScreenShareStarted;
                App.CRVideo.VideoSDK.notifyScreenShareStopped -= notifyScreenShareStopped;
                App.CRVideo.VideoSDK.notifyMediaStart -= notifyMediaStart;
                App.CRVideo.VideoSDK.notifyMediaStop -= notifyMediaStop;
                App.CRVideo.VideoSDK.audioDevChanged -= audioDevChanged;
                App.CRVideo.VideoSDK.videoDevChanged -= videoDevChanged;
                App.CRVideo.VideoSDK.setDNDStatusFail -= setDNDStatusFail;
                App.CRVideo.VideoSDK.setDNDStatusSuccess -= setDNDStatusSuccess;
                App.CRVideo.VideoSDK.netStateChanged -= netStateChanged;
                App.CRVideo.VideoSDK.userEnterMeeting -= userEnterMeeting;
                App.CRVideo.VideoSDK.userLeftMeeting -= userLeftMeeting;             
                App.CRVideo.VideoSDK.notifyAllAudioClose -= notifyAllAudioClose;
                App.CRVideo.VideoSDK.audioStatusChanged -= audioStatusChanged;
                App.CRVideo.VideoSDK.videoStatusChanged -= videoStatusChanged;
                App.CRVideo.VideoSDK.micEnergyUpdate -= micEnergyUpdate;
            }
        }

        public void initMeeting(int meetID)
        {
            this.Title = "会议ID: " + Convert.ToString(meetID);

            App.CRVideo.VideoSDK.setDNDStatus(1, "");   //入会成功后设置呼叫免打扰            

            mVideoWall.initPage();
            mScreen.initPage();

            int mainPage = App.CRVideo.VideoSDK.getCurrentMainPage(); //获取当前的主功能页
            switch (mainPage)
            {
                case (int)MAIN_PAGE_TYPE.MAINPAGE_VIDEOWALL:
                    mVideoWall.Visibility = Visibility.Visible;
                    break;
                default:
                    break;
            }

            List<MemberInfo> members = JsonConvert.DeserializeObject<List<MemberInfo>>(App.CRVideo.VideoSDK.getAllMembers());
            for(int i = 0; i < members.Count; i ++)
            {
                MemberInfo memItem = members[i];
                mMemBerList.addMember(memItem.userID, memItem.nickName, memItem.audioStatus == 3, memItem.videoStatus == 3);
            }
        }

        private void audioStatusChanged(object sender, ICloudroomVideoSDKEvents_audioStatusChangedEvent e)
        {
            mMemBerList.setMicStatus(e.p_userID, e.p_newStatus == 3);
        }

        private void videoStatusChanged(object sender, ICloudroomVideoSDKEvents_videoStatusChangedEvent e)
        {
            mMemBerList.setVideoStatus(e.p_userID, e.p_newStatus == 3);

        }

        private void micEnergyUpdate(object sender, ICloudroomVideoSDKEvents_micEnergyUpdateEvent e)
        {
            mMemBerList.setAudioEnergy(e.p_userID, e.p_newLevel);
        }


        //对方进入会话
        private void userEnterMeeting(object sender, ICloudroomVideoSDKEvents_userEnterMeetingEvent e)
        {
            Console.WriteLine("userEnterMeeting:" + e.p_userID);
            //更新显示的视频窗口
            mVideoWall.updateWatchVideos();
            MemberInfo member = JsonConvert.DeserializeObject<MemberInfo>(App.CRVideo.VideoSDK.getMemberInfo(e.p_userID));
           
            mMemBerList.addMember(member.userID, member.nickName, member.audioStatus == 3, member.videoStatus == 3);
        }

        private void userLeftMeeting(object sender, ICloudroomVideoSDKEvents_userLeftMeetingEvent e)
        {
            mVideoWall.updateWatchVideos();
            mMemBerList.removeMember(e.p_userID);
        }

        public bool mIsSelfClose = true;
        public void netStateChanged(object sender, ICloudroomVideoSDKEvents_netStateChangedEvent e)
        {
            netStateBar.Value = e.p_level;
        }

        private void Window_ContentRendered(object sender, EventArgs e)
        {
            mScreen.Height = MainPanel.RenderSize.Height;
            mScreen.Width = MainPanel.RenderSize.Width;

          

            mVideoWall.Height = MainPanel.RenderSize.Height;
            mVideoWall.Width = MainPanel.RenderSize.Width;

            mMediaShare.Height = MainPanel.RenderSize.Height;
            mMediaShare.Width = MainPanel.RenderSize.Width;
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            e.Cancel = false;
            if (mIsSelfClose)
            {
                if (MessageBoxResult.No == System.Windows.MessageBox.Show(this, "你是否要退出会议？", "退出", MessageBoxButton.YesNo))
                {
                    e.Cancel = true;
                    return;
                }
            }
            unInitPage(); //关闭各个功能子窗体

            App.CRVideo.VideoSDK.setDNDStatus(0, "");   //取消呼叫免打扰
            App.CRVideo.VideoSDK.exitMeeting();     //离开会议
        }

        public void unInitPage()
        {
            initDelegate(false);
            
            if (mRecord != null)
            {
                mRecord.closeForm();
                mRecord = null;
            }
            if (mDevicesSet != null)
            {
                mDevicesSet.uninit();
                mDevicesSet = null;
            }
            if (mInvite != null)
            {
                mInvite.initDelegate(false);
                mInvite = null;
            }

            mVideoWall.unInitPage();
            mScreen.unInitPage();

            mMemBerList.initDelegate(false);

            this.Owner.ShowInTaskbar = true;
            this.Owner.Visibility = Visibility.Visible;
        }


        private void btnInvite_Click(object sender, RoutedEventArgs e)
        {
            mInvite = new Invite(false);
            mInvite.Owner = this;
            mInvite.Show();
        }
        //录制
        private void btnRecord_Click(object sender, RoutedEventArgs e)
        {
            if (mRecord.IsVisible == true)
            {
                mRecord.Visibility = Visibility.Hidden;
            }
            else
            {
                mRecord.Owner = this;
                mRecord.Show();
            }
        }

        private void setDNDStatusFail(object sender, ICloudroomVideoSDKEvents_setDNDStatusFailEvent e)
        {
        }

        private void setDNDStatusSuccess(object sender, ICloudroomVideoSDKEvents_setDNDStatusSuccessEvent e)
        {

        }

        private void notifyAllAudioClose(object sender, ICloudroomVideoSDKEvents_notifyAllAudioCloseEvent e)
        {
            mVideoWall.notifyCloseAllMics(e.p_userID);
        }

        public void startScreenShareRslt(object sender, ICloudroomVideoSDKEvents_startScreenShareRsltEvent e)
        {
            if (e.p_sdkErr != (int)VCALLSDK_ERR_DEF.VCALLSDK_NOERR)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "开启屏幕共享失败:" + CRError.Instance.getError(e.p_sdkErr) });
            }
            else
            {
                mVideoWall.Visibility = Visibility.Collapsed;
                mScreen.Visibility = Visibility.Visible;
                mMediaShare.Visibility = Visibility.Collapsed;
                btnVideoWall.Visibility = Visibility.Collapsed;
                ShareBtn.Content = "停止共享";
                this.WindowState = System.Windows.WindowState.Minimized;

            }
        }

        public void stopScreenShareRslt(object sender, ICloudroomVideoSDKEvents_stopScreenShareRsltEvent e)
        {
            if (e.p_sdkErr != (int)VCALLSDK_ERR_DEF.VCALLSDK_NOERR)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "停止屏幕共享失败:" + CRError.Instance.getError(e.p_sdkErr) });
            }
            else
            {
                mVideoWall.Visibility = Visibility.Visible;
                mScreen.Visibility = Visibility.Collapsed;
                mMediaShare.Visibility = Visibility.Collapsed;
                btnVideoWall.Visibility = Visibility.Visible;
                ShareBtn.Content = "共享...";
                this.WindowState = System.Windows.WindowState.Normal;

            }
        }

        private void notifyScreenShareStarted(object sender, ICloudroomVideoSDKEvents_notifyScreenShareStartedEvent e)
        {
            mVideoWall.Visibility = Visibility.Collapsed;
            mScreen.Visibility = Visibility.Visible;
            mMediaShare.Visibility = Visibility.Collapsed;
            btnVideoWall.Visibility = Visibility.Collapsed;
            ShareBtn.IsEnabled = false;

        }
        //对方关闭屏幕共享
        private void notifyScreenShareStopped(object sender, EventArgs e)
        {
            mVideoWall.Visibility = Visibility.Visible;
            mScreen.Visibility = Visibility.Collapsed;
            mMediaShare.Visibility = Visibility.Collapsed;
            btnVideoWall.Visibility = Visibility.Visible;
            ShareBtn.IsEnabled = true;
        }

        private void notifyMediaStop(object sender, ICloudroomVideoSDKEvents_notifyMediaStopEvent e)
        {
            mMediaShare.updateCtrl(false);
            mScreen.Visibility = Visibility.Collapsed;
            mMediaShare.Visibility = Visibility.Collapsed;
            btnVideoWall.Visibility = Visibility.Visible;
            mVideoWall.Visibility = Visibility.Visible;
            ShareBtn.Content = "共享...";
            ShareBtn.IsEnabled = true;    
        }
        private void notifyMediaStart(object sender, ICloudroomVideoSDKEvents_notifyMediaStartEvent e)
        {
            mMediaShare.updateCtrl(true);
            mVideoWall.Visibility = Visibility.Collapsed;
            mScreen.Visibility = Visibility.Collapsed;
            btnVideoWall.Visibility = Visibility.Collapsed;
            mMediaShare.Visibility = Visibility.Visible;
            mMediaShare.disableTool(e.p_userID);
            if (e.p_userID == Login.Instance.myUserID)
            {
                ShareBtn.Content = "停止共享";
                ShareBtn.IsEnabled = true;
            }
            else
            {
                ShareBtn.IsEnabled = false;
            }
        }

        //音频设备有变化
        public void audioDevChanged(object sender, EventArgs e)
        {
            if(mDevicesSet != null)
                mDevicesSet.initDevs();
        }

        public void videoDevChanged(object sender, ICloudroomVideoSDKEvents_videoDevChangedEvent e)
        {
            //如果是本地设备变化则更新设备信息
            if (e.p_userID == Login.Instance.myUserID && mDevicesSet != null)
            {
                mDevicesSet.initDevs();
            }
        }

        private void btn_mute_all(object sender, RoutedEventArgs e)
        {
            App.CRVideo.VideoSDK.setAllAudioClose();
        }

        private void btn_share_click(object sender, RoutedEventArgs e)
        {
            if (mVideoWall.IsVisible)
            {
                ShareMenu.IsOpen = true;
                return;
            }

            if (mScreen.IsVisible)
            {
                App.CRVideo.VideoSDK.stopScreenShare();
                return;
            }

            if (mMediaShare.IsVisible)
            {
                App.CRVideo.VideoSDK.stopPlayMedia();
                return;
            }
        }

        private void btn_screen_share(object sender, RoutedEventArgs e)
        {
            ScreenShareCfg cfg = new ScreenShareCfg();
            App.CRVideo.VideoSDK.setScreenShareCfg(JsonConvert.SerializeObject(cfg));
            App.CRVideo.VideoSDK.startScreenShare();
        }

        private void btn_area_screen(object sender, RoutedEventArgs e)
        {
            ScreenAreaShareCfg cfg = new ScreenAreaShareCfg();

            Point pos = mScreen.PointToScreen(new Point(0, 0));
            cfg.catchRect.left = (int)pos.X;
            cfg.catchRect.top = (int)pos.Y; ; //加上顶部工具栏
            cfg.catchRect.width = (int)mScreen.Width;
            cfg.catchRect.height = (int)mScreen.Height;
            App.CRVideo.VideoSDK.setScreenShareCfg(JsonConvert.SerializeObject(cfg));
            App.CRVideo.VideoSDK.startScreenShare();
        }

        private void btn_local_media(object sender, RoutedEventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog();
            dialog.Multiselect = false;
            dialog.Title = "选择播放文件";
            dialog.Filter = "常见格式(*.avi *.flv *.mp3 *.mp4 *.wmv *.mkv *.mov *.3gp *.wma *.wav)|*.avi;*.flv;*.mp3;*.mp4;*.wmv;*.mkv;*.mov;*.3gp;*.wma;*.wav";

            if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                if (ShareBtn.IsEnabled == true)
                {
                   App.CRVideo.VideoSDK.stopPlayMedia();
                   App.CRVideo.VideoSDK.startPlayMedia(dialog.FileName, 0, 0);

                }
            }
        }

        private void btn_url_media(object sender, RoutedEventArgs e)
        {
            InputWnd inputWnd = new InputWnd();
            inputWnd.setTitle("输入Url支持(http/rtmp/rtsp)");
            if(inputWnd.ShowDialog() == true)
            {
                string url = inputWnd.getInputText();
                if (string.IsNullOrEmpty(url.Trim()))
                {
                    System.Windows.MessageBox.Show("url为空");
                    return;
                }
                if (ShareBtn.IsEnabled == true)
                {
                    App.CRVideo.VideoSDK.stopPlayMedia();
                    App.CRVideo.VideoSDK.startPlayMedia(url.Trim(), 0, 0);
                }
                
            }
        }

        private void btn_setting_click(object sender, RoutedEventArgs e)
        {
            mDevicesSet.Owner = Window.GetWindow(this);
            mDevicesSet.ShowDialog();
        }

        private void btn_tow_video(object sender, RoutedEventArgs e)
        {
           int mode = App.CRVideo.VideoSDK.getVideoWallMode2();
            if (mode != 2)
                App.CRVideo.VideoSDK.setVideoWallMode2((int)VIDEOWALL_MODE.VLO_WALL2);
        }

        private void btn_four_video(object sender, RoutedEventArgs e)
        {
            int mode = App.CRVideo.VideoSDK.getVideoWallMode2();
            if (mode != 4)
                App.CRVideo.VideoSDK.setVideoWallMode2((int)VIDEOWALL_MODE.VLO_WALL4);
       
        }

        private void btn_six_video(object sender, RoutedEventArgs e)
        {
            int mode = App.CRVideo.VideoSDK.getVideoWallMode2();
            if (mode != 6)
                App.CRVideo.VideoSDK.setVideoWallMode2((int)VIDEOWALL_MODE.VLO_WALL6);
       
        }

        private void btn_video_wall_menu(object sender, RoutedEventArgs e)
        {
            VideoWallMenu.IsOpen = true;
        }

    }
    //进度条转换器
    public class NetProgressBarValueConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            double v = (double)value;

            string imageUri = "/Res/net_0.png";

            if (v > 7)
            {
                imageUri = "/Res/net_5.png";
            }
            else if (v > 4)
            {
                imageUri = "/Res/net_3.png";
            }
            else
            {
                imageUri = "/Res/net_1.png";
            }

            BitmapImage img = new BitmapImage(new Uri(imageUri, UriKind.Relative));

            return img;
        }

        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }

        
}
