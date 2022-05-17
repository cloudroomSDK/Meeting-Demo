using System;
using System.Collections.Generic;
using AxnpcloudroomvideosdkLib;
using System.Windows;
using Newtonsoft.Json;
using System.Drawing;
using System.Windows.Controls;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using System.Windows.Media.Imaging;
using System.Windows.Data;
using System.IO;

namespace Meeting_WPF
{
    /// <summary>
    /// VideoWallPage.xaml 的交互逻辑
    /// </summary>
    public partial class VideoWallPage : System.Windows.Controls.UserControl
    {
        private Dictionary<int, VideoUI> mVideoUIs = new Dictionary<int, VideoUI>();
        private Dictionary<string, string> mUserIndex = new Dictionary<string, string>();

        private MeetingMainWin.VideoWallLayoutChangeEvent mLayoutChangeEvt;  //视频布局变化事件对象

        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { System.Windows.MessageBox.Show(Window.GetWindow(this), desc); }
        public VideoWallPage(MeetingMainWin.VideoWallLayoutChangeEvent evt)
        {
            InitializeComponent();
            initDeletegate(true);
            
            mLayoutChangeEvt = evt;
            mLayoutChangeEvt.VideoRationChanged += new MeetingMainWin.VideoUIRationChangeEventHandler(LayoutChangeEvt_VideoRationChanged);     
        }

        public void initPage()
        {
            //打开本地设备
            App.CRVideo.VideoSDK.openVideo(Login.Instance.myUserID);
            App.CRVideo.VideoSDK.openMic(Login.Instance.myUserID);
            App.CRVideo.VideoSDK.speakerMute = 0;
        }

        private void initDeletegate(bool isInit)
        {
            if (isInit)
            {
                App.CRVideo.VideoSDK.micEnergyUpdate += micEnergyUpdate;
                App.CRVideo.VideoSDK.audioStatusChanged += audioStatusChanged;
                App.CRVideo.VideoSDK.openVideoDevRslt += openVideoDevRslt;
                App.CRVideo.VideoSDK.videoDevChanged += videoDevChanged;
                App.CRVideo.VideoSDK.videoStatusChanged += videoStatusChanged;
                App.CRVideo.VideoSDK.notifyVideoWallMode2 += notifyVideoWallMode2;
                App.CRVideo.VideoSDK.notifyMainVideoChanged += notifyMainVideoChanged;
             
            }
            else
            {
                App.CRVideo.VideoSDK.micEnergyUpdate -= micEnergyUpdate;
                App.CRVideo.VideoSDK.audioStatusChanged -= audioStatusChanged;
                App.CRVideo.VideoSDK.openVideoDevRslt -= openVideoDevRslt;
                App.CRVideo.VideoSDK.videoDevChanged -= videoDevChanged;
                App.CRVideo.VideoSDK.videoStatusChanged -= videoStatusChanged;
                App.CRVideo.VideoSDK.notifyVideoWallMode2 -= notifyVideoWallMode2;
                App.CRVideo.VideoSDK.notifyMainVideoChanged -= notifyMainVideoChanged;
            }
        }

        public void updateWatchVideos()
        {
            foreach (int i in mVideoUIs.Keys) //清空之前的视频显示信息
            {
                mVideoUIs[i].clear();
                mVideoUIs[i].setVideo("", 0);
            }

            mLayoutChangeEvt.videoUIs.Clear();
            //主视频放到前面，普通视频放到后面
            List<UserVideo> vidList = JsonConvert.DeserializeObject<List<UserVideo>>(App.CRVideo.VideoSDK.getWatchableVideos()); //获取所有可观看的摄像头列表         
            for (int i = 0; i < vidList.Count; i++)
            {
                UserVideo item = vidList[i];
                if (item.userID == App.CRVideo.VideoSDK.mainVideo)
                {
                    vidList.RemoveAt(i);
                    vidList.Insert(0, item); //将主视频放到list 最前头
                    break;
                }
            }

            for (int i = 0; i < vidList.Count; i++)
            {
                if (!mVideoUIs.ContainsKey(i))
                {
                    break;
                }
                int mode = App.CRVideo.VideoSDK.getVideoWallMode2(); 
                UserVideo uVideo = vidList[i];
                mVideoUIs[i].setVideo(uVideo.userID, uVideo.videoID, true);
               
                mLayoutChangeEvt.videoUIs.Add(new MeetingMainWin.VideoUI(uVideo.userID, uVideo.videoID));  
            }

            mLayoutChangeEvt.OnContentChanged();
        }        

        private void createVideoUIs(int videoCount)
        {
            for (int i = 0; i < videoCount; i++)
            {
                if (!mVideoUIs.ContainsKey(i)) //如果视频窗口尚未创建，则先创建之
                {
                    VideoUI videoUI = new VideoUI();
                    videoUI.Name = "video_" + i;
                    WindowsFormsHost host = new WindowsFormsHost();
                    host.Child = videoUI;
                    host.Tag = i;   //对应的窗口序号
                    host.Visibility = Visibility.Collapsed;    //先默认隐藏，等移动到正确的位置后再显示
                    host.HorizontalAlignment = System.Windows.HorizontalAlignment.Stretch;
                    host.VerticalAlignment = VerticalAlignment.Stretch;
                    host.Margin = new Thickness(2, 2, 2, 2);
                    grid_videos.Children.Add(host);
                    mVideoUIs.Add(i, videoUI);
                }
            }

            updateWatchVideos();
        }

        private void InitRows(Grid g, int rowCount, float rowHeight)
        {
            while(g.RowDefinitions.Count > 0)
            {
                g.RowDefinitions.RemoveAt(0);
            }
                      
            while (rowCount-- > 0)
            {
                RowDefinition rd = new RowDefinition();
                rd.Height = new GridLength(rowHeight);
                g.RowDefinitions.Add(rd);                
            }
        }
        private void InitColumns(Grid g, int colCount, float columnWidth)
        {
            while (g.ColumnDefinitions.Count > 0)
            {
                g.ColumnDefinitions.RemoveAt(0);
            }
          

            while (colCount-- > 0)
            {
                ColumnDefinition rd = new ColumnDefinition();
                rd.Width = new GridLength(columnWidth);
                g.ColumnDefinitions.Add(rd);
            }
        }

        private float margin = 20F;   //左右两侧的边距
        private float space = 2F;     //中间的缝隙宽度

        private void setVideoLayout_2(float ration)
        {
            if (this.ActualWidth > -0.000001 && this.ActualWidth < 0.000001)
                return;

            margin = 10;
            List<RectangleF> rects = CRTools.getVideoUiRect(2, (float)this.ActualWidth, (float)this.ActualHeight, margin, space, ration);

            InitRows(grid_videos, 1, rects[0].Height + margin / 2);
            InitColumns(grid_videos, 2, rects[0].Width + margin / 2);

            mLayoutChangeEvt.layoutCount = 2;
            for (int i = 0; i < mVideoUIs.Count; i++)
            {
                WindowsFormsHost host = (WindowsFormsHost)grid_videos.Children[i];
                host.Visibility = Visibility.Collapsed;
                if (i < 2)
                {
                    Grid.SetRow(host, 0);
                    Grid.SetColumn(host, i);

                    Grid.SetRowSpan(host, 1);
                    Grid.SetColumnSpan(host, 1);

                    host.MinWidth = rects[i].Width;
                    host.MinHeight = rects[i].Height;
                    host.Visibility = Visibility.Visible;
                }          
            }
            mLayoutChangeEvt.OnLayoutChanged();
        }

        private void setVideoLayout_4(float ration)
        {
            if (this.ActualWidth > -0.000001 && this.ActualWidth < 0.000001)
                return;

            margin = 10;
            List<RectangleF> rects = CRTools.getVideoUiRect(4, (float)this.ActualWidth, (float)this.ActualHeight, margin, space, ration);

            InitRows(grid_videos, 2, rects[0].Height + margin / 2);
            InitColumns(grid_videos, 2, rects[0].Width + margin / 2);

            mLayoutChangeEvt.layoutCount = 4;
            for (int i = 0; i < mVideoUIs.Count; i++)
            {
                WindowsFormsHost host = (WindowsFormsHost)grid_videos.Children[i];
                host.Visibility = Visibility.Collapsed;
                if (i < 4)
                {
                    int r = i / 2; int c = i % 2;

                    Grid.SetRow(host, r);
                    Grid.SetColumn(host, c);
                    Grid.SetRowSpan(host, 1);
                    Grid.SetColumnSpan(host, 1);

                    host.MinWidth = rects[i].Width;
                    host.MinHeight = rects[i].Height;
                    host.Visibility = Visibility.Visible;
                }
            }
            mLayoutChangeEvt.OnLayoutChanged();
        }

        private void setVideoLayout_6(float ration)
        {
            if (this.ActualWidth > -0.000001 && this.ActualWidth < 0.000001)
                return;

            margin = 10;
            List<RectangleF> rects = CRTools.getVideoUiRect(6, (float)this.ActualWidth, (float)this.ActualHeight, margin, space, ration);

            InitRows(grid_videos, 3, rects[1].Height + margin / 2);
            InitColumns(grid_videos, 3, rects[1].Width + margin / 2);

            mLayoutChangeEvt.layoutCount = 6;
            for (int i = 0; i < mVideoUIs.Count; i++)
            {
                WindowsFormsHost host = (WindowsFormsHost)grid_videos.Children[i];
                host.Visibility = Visibility.Collapsed;
                if (i < 6)
                {
                    Grid.SetRowSpan(host, 1);
                    Grid.SetColumnSpan(host, 1);
                    if (i == 0) //(0,0)
                    {
                        Grid.SetRow(host, 0);
                        Grid.SetColumn(host, 0);
                        //第一个大视频行列各占两格
                        Grid.SetRowSpan(host, 2);
                        Grid.SetColumnSpan(host, 2);
                    }
                    else if(i == 1) //(0,2)
                    {
                        Grid.SetRow(host, 0);
                        Grid.SetColumn(host, 2);
                    }
                    else if (i == 2) //(1,2)
                    {
                        Grid.SetRow(host, 1);
                        Grid.SetColumn(host, 2);
                    }
                    else ////(2,0) (2,1) (2,2)
                    {
                        Grid.SetRow(host, 2);
                        Grid.SetColumn(host, i%3);
                    }

                    host.MinWidth = rects[i].Width;
                    host.MinHeight = rects[i].Height;
                    host.Visibility = Visibility.Visible;
                }
            }
            mLayoutChangeEvt.OnLayoutChanged();
        }

        //麦克风音量波动
        public void micEnergyUpdate(object sender, ICloudroomVideoSDKEvents_micEnergyUpdateEvent e)
        {
            foreach (var videoUI in mVideoUIs.Values)
            {
                videoUI.updateMicEnergy(e.p_userID, e.p_newLevel);                
            }
        }

        private void audioStatusChanged(object sender, ICloudroomVideoSDKEvents_audioStatusChangedEvent e)
        {
            foreach (var videoUI in mVideoUIs.Values)
            {
                videoUI.updateMicStatus(e.p_userID, e.p_newStatus);
            }
        }

        private void openVideoDevRslt(object sender, ICloudroomVideoSDKEvents_openVideoDevRsltEvent e)
        {
            Console.WriteLine("open video dev:" + e.p_videoID);

            if(e.p_isSucceed == false)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "打开视频设备失败:" + e.p_videoID });
            }
        }

        //视频设备有变化
        public void videoDevChanged(object sender, ICloudroomVideoSDKEvents_videoDevChangedEvent e)
        {
            updateWatchVideos();
        }
        //音频状态发生变化
       
        //视频状态变化
        public void videoStatusChanged(object sender, ICloudroomVideoSDKEvents_videoStatusChangedEvent e)
        {
            Console.WriteLine("video StatusChanged:" + e.p_oldStatus + "->" + e.p_newStatus);

            updateWatchVideos();
          
        }

        public void notifyCloseAllMics(string userOperator)
        {
            foreach (var videoUI in mVideoUIs.Values)
            {
                if(userOperator != videoUI.userID)
                {
                    videoUI.updateMicStatus((int)ASTATUS.ACLOSE);
                }                
            }
        }

        private void notifyVideoWallMode2(object sender, ICloudroomVideoSDKEvents_notifyVideoWallMode2Event e)
        {
            if (e.p_model == (int)VIDEOWALL_MODE.VLO_WALL2)
            {
                createVideoUIs(2);
                setVideoLayout_2(mLayoutChangeEvt.videoRation); 
            }
            else if (e.p_model == (int)VIDEOWALL_MODE.VLO_WALL4)
            {
                createVideoUIs(4);
                setVideoLayout_4(mLayoutChangeEvt.videoRation);
                
            }
            else if (e.p_model == (int)VIDEOWALL_MODE.VLO_WALL6)
            {
                createVideoUIs(6);
                setVideoLayout_6(mLayoutChangeEvt.videoRation);  
            }
            else
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "不支持显示的分屏模式:" + e.p_model });
            }
        }

        private void notifyMainVideoChanged(object sender, EventArgs e)
        {
            updateWatchVideos();
        }

        public void unInitPage()
        {
            mVideoUIs.Clear();
            mUserIndex.Clear();

            initDeletegate(false);
        }

        private void UserControl_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            //界面尺寸变化，更新视频画面布局
            int mode = App.CRVideo.VideoSDK.getVideoWallMode2();
            if (mode == 4) 
            {
                createVideoUIs(4);
                setVideoLayout_4(mLayoutChangeEvt.videoRation);
            }
            else if (mode == 6)
            {
                createVideoUIs(6);
                setVideoLayout_6(mLayoutChangeEvt.videoRation);
            }
            else
            {
                createVideoUIs(2);
                setVideoLayout_2(mLayoutChangeEvt.videoRation);
            }
        }

        private void LayoutChangeEvt_VideoRationChanged()
        {
            Console.WriteLine("videoRation:{0}", mLayoutChangeEvt.videoRation);
            int mode = App.CRVideo.VideoSDK.getVideoWallMode2();
            if (mode == 4)
            {
                setVideoLayout_4(mLayoutChangeEvt.videoRation);
            }
            else if (mode == 6)
            {
                setVideoLayout_6(mLayoutChangeEvt.videoRation);
            }
            else 
            {
                setVideoLayout_2(mLayoutChangeEvt.videoRation);
            }
        } 
    }
        //进度条转换器
    public class MicProgressBarValueConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            double v = (double)value;

            string imageUri = "/Res/mic_0.png";

            if (v > 7)
            {
                imageUri = "/Res/mic_3.png";
            }
            else if (v > 4)
            {
                imageUri = "/Res/mic_2.png";
            }
            else
            {
                imageUri = "/Res/mic_1.png";
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
