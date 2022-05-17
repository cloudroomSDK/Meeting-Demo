using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Threading;
using System.IO;
using Newtonsoft.Json;
using AxnpcloudroomvideosdkLib;
using System.Drawing;
using System.Windows.Media;
using System.Windows.Controls;
using System.Text.RegularExpressions;

namespace Meeting_WPF
{
    /// <summary>
    /// Record.xaml 的交互逻辑
    /// </summary>
    public partial class RecordWin : Window
    {
        private enum REC_CONTENT_TYPE { VIDEOWALL, SCREEN, MEDIASHARE }
        private string mLocMixId = "1";
        private int mDefaultQP = 24;

        private string mCloudMixId;
        private MIXER_STATE localRecordST;
        private MIXER_STATE cloudRecordST;
        private REC_CONTENT_TYPE recordContent;//当前录制的内容
        private bool mbExit;

        private MeetingMainWin.VideoWallLayoutChangeEvent mLayoutChangeEvt;

        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { MessageBox.Show(this, desc); }
        public RecordWin(MeetingMainWin.VideoWallLayoutChangeEvent evt)
        {
            InitializeComponent();
            initDelegate(true);

            localRecordST = MIXER_STATE.MST_NULL;
            cloudRecordST = MIXER_STATE.MST_NULL;
            mCloudMixId = "";
            mbExit = false;
            recordContent = REC_CONTENT_TYPE.VIDEOWALL;
            RecordFps.Text = "15";
            RecordBps.Text = "350000";

            mLayoutChangeEvt = evt;
            mLayoutChangeEvt.LayoutChanged += LayoutChangeEvt_LayoutChanged;
            mLayoutChangeEvt.VideoContentChanged += LayoutChangeEvt_VideoContentChanged;
            mLayoutChangeEvt.VideoRationChanged += LayoutChangeEvt_VideoRationChanged;

            rbnLocal.IsChecked = true;
            //本地录制状态
            localRecordST = (MIXER_STATE)(App.CRVideo.VideoSDK.getLocMixerState(mLocMixId));

            //获取我的云端录制状态
            cloudRecordST = MIXER_STATE.MST_NULL;
            string cloudMixerInfoListStr = App.CRVideo.VideoSDK.getAllCloudMixerInfo();
            List<CloudMixerInfo> cloudMixerInfoList = JsonConvert.DeserializeObject<List<CloudMixerInfo>>(cloudMixerInfoListStr);
            for (int i = 0; i < cloudMixerInfoList.Count; i++)
            {
                if ( cloudMixerInfoList[0].owner==Login.Instance.myUserID )
                {
                    cloudRecordST = (MIXER_STATE)(cloudMixerInfoList[0].state);
                    mCloudMixId = cloudMixerInfoList[0].ID;
                    break;
                }
            }

            updateRecordStateUI();

        }

        public void initDelegate(bool isInit)
        {
            if(isInit)
            {
                App.CRVideo.VideoSDK.locMixerStateChanged += Meeting_locMixerStateChanged;
                App.CRVideo.VideoSDK.locMixerOutputInfo += Meeting_locMixerOutputInfo;
                App.CRVideo.VideoSDK.createCloudMixerFailed += Meeting_createCloudMixerFailed;
                App.CRVideo.VideoSDK.cloudMixerStateChanged += Meeting_cloudMixerStateChanged;
                App.CRVideo.VideoSDK.cloudMixerOutputInfoChanged += Meeting_cloudMixerOutputInfoChanged;

                App.CRVideo.VideoSDK.startScreenShareRslt += startScreenShareRslt;
                App.CRVideo.VideoSDK.stopScreenShareRslt += stopScreenShareRslt;
                App.CRVideo.VideoSDK.notifyScreenShareStarted += notifyScreenShareStarted;
                App.CRVideo.VideoSDK.notifyScreenShareStopped += notifyScreenShareStopped;
                App.CRVideo.VideoSDK.notifyMediaStart += notifyMediaStart;
                App.CRVideo.VideoSDK.notifyMediaStop += notifyMediaStop;
            }
            else
            {
                App.CRVideo.VideoSDK.locMixerStateChanged -= Meeting_locMixerStateChanged;
                App.CRVideo.VideoSDK.locMixerOutputInfo -= Meeting_locMixerOutputInfo;
                App.CRVideo.VideoSDK.createCloudMixerFailed -= Meeting_createCloudMixerFailed;
                App.CRVideo.VideoSDK.cloudMixerStateChanged -= Meeting_cloudMixerStateChanged;
                App.CRVideo.VideoSDK.cloudMixerOutputInfoChanged -= Meeting_cloudMixerOutputInfoChanged;

                App.CRVideo.VideoSDK.startScreenShareRslt -= startScreenShareRslt;
                App.CRVideo.VideoSDK.stopScreenShareRslt -= stopScreenShareRslt;
                App.CRVideo.VideoSDK.notifyScreenShareStarted -= notifyScreenShareStarted;
                App.CRVideo.VideoSDK.notifyScreenShareStopped -= notifyScreenShareStopped;
                App.CRVideo.VideoSDK.notifyMediaStart -= notifyMediaStart;
                App.CRVideo.VideoSDK.notifyMediaStop -= notifyMediaStop;
            }
        }

        MIXER_STATE getMixState()
        {
            if (cloudRecordST != MIXER_STATE.MST_NULL)
                return cloudRecordST;
            return localRecordST;
        }

        void updateRecordStateUI()
        {
            MIXER_STATE mixSt = getMixState();
            if (mixSt != MIXER_STATE.MST_NULL)
            {
                if (cloudRecordST != MIXER_STATE.MST_NULL)
                {
                    rbnCloud.IsChecked = true;
                }
                else
                {
                    rbnLocal.IsChecked = true;
                }

                RecordFps.IsEnabled = false;
                RecordBps.IsEnabled = false;
                layoutSize.IsEnabled = false;
                rbnLocal.IsEnabled = false;
                rbnCloud.IsEnabled = false;

                if (mixSt == MIXER_STATE.MST_STARTING)
                {
                    btnRecordOpr.Content = "启动中...";
                    btnRecordOpr.IsEnabled = false;
                }
                else
                {
                    btnRecordOpr.Content = "停止录制";
                    btnRecordOpr.IsEnabled = true;
                }
            }
            else
            {
                RecordFps.IsEnabled = true;
                RecordBps.IsEnabled = true;
                layoutSize.IsEnabled = true;
                rbnLocal.IsEnabled = true;
                rbnCloud.IsEnabled = true;
                btnRecordOpr.Content = "开始录制";
                btnRecordOpr.IsEnabled = true;
            }
        }

        void Meeting_locMixerStateChanged(object sender, ICloudroomVideoSDKEvents_locMixerStateChangedEvent e)
        {
            Console.WriteLine("loc record state changed, state:{0}", e.p_state);
            localRecordST = (MIXER_STATE)e.p_state;
            updateRecordStateUI();
        }

        void Meeting_locMixerOutputInfo(object sender, ICloudroomVideoSDKEvents_locMixerOutputInfoEvent e)
        {
            LocMixerOutputInfoObj obj = JsonConvert.DeserializeObject<LocMixerOutputInfoObj>(e.p_outputInfo);
            if (obj.state == Convert.ToInt32(LOCMIXER_OUTPUT_STATE.LOCMOST_INFOUPDATE)
                || obj.state == Convert.ToInt32(LOCMIXER_OUTPUT_STATE.LOCMOST_CLOSE))
            {
                label_record_desc.Text = String.Format("录制时长:{0}s, 文件大小:{1}kb", obj.duration / 1000, obj.filesize / 1024);
            }

            if (obj.state == Convert.ToInt32(LOCMIXER_OUTPUT_STATE.LOCMOST_ERR))
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "录制发生异常:" + CRError.Instance.getError(obj.errCode) });

                //结束本地录制
                App.CRVideo.VideoSDK.destroyLocMixer(mLocMixId);
            }
        }

        void Meeting_createCloudMixerFailed(object sender, ICloudroomVideoSDKEvents_createCloudMixerFailedEvent e)
        {
            Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "开启云端录制失败:" + CRError.Instance.getError(e.p_err) });
        }

        void Meeting_cloudMixerStateChanged(object sender, ICloudroomVideoSDKEvents_cloudMixerStateChangedEvent e)
        {
            if (e.p_mixerID != mCloudMixId)
            {
                return;
            }

            Console.WriteLine("cloud record state changed, state:{0}", e.p_state);
            cloudRecordST = (MIXER_STATE)e.p_state;
            updateRecordStateUI();

            if (cloudRecordST == MIXER_STATE.MST_NULL)
            {
                CloudMixerErrInfo errInfo = JsonConvert.DeserializeObject<CloudMixerErrInfo>(e.p_exParam);
                if (errInfo.err != 0)
                {
                    Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "录制异常结束:" + CRError.Instance.getError(errInfo.err) });
                }
            }
        }

        void Meeting_cloudMixerOutputInfoChanged(object sender, ICloudroomVideoSDKEvents_cloudMixerOutputInfoChangedEvent e)
        {
            if (e.p_mixerID != mCloudMixId)
            {
                return;
            }

            CloudMixerOutputInfo obj = JsonConvert.DeserializeObject<CloudMixerOutputInfo>(e.p_jsonStr);
            if ( obj.state == Convert.ToInt32(CLOUDMIXER_OUTPUT_STATE.CLOUDMOST_STOPPED) )
            {
                label_record_desc.Text = String.Format("录制时长:{0}s, 文件大小:{1}kb", obj.duration / 1000, obj.fileSize / 1024);
            }

            if (obj.state == Convert.ToInt32(CLOUDMIXER_OUTPUT_STATE.CLOUDMOST_FAIL))
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "录制发生异常:" + CRError.Instance.getError(obj.errCode) });
                //结束云端录制
                App.CRVideo.VideoSDK.destroyCloudMixer(obj.id);
            }
        }

        private void btnRecordOpr_Click(object sender, RoutedEventArgs e)
        {
            if (rbnLocal.IsChecked == true)
            {
                localRecord();
            }
            else if (rbnCloud.IsChecked == true)
            {
                cloudRecord();
            }
        }

        public string timeNumber2String(int number)
        {
            int h, m, s;
            h = m = s = 0;

            h = number / 3600;
            m = (number - h * 3600) / 60;
            s = number - h * 3600 - m * 60;

            string tickStr = "";
            if (h > 0) { tickStr += h + "时"; }
            if (m > 0) { tickStr += m + "分"; }
            if (s > 0) { tickStr += s + "秒"; }
            return tickStr;
        }

        private void btnOpenDir_Click(object sender, RoutedEventArgs e)
        {
            if (rbnLocal.IsChecked == true)
            {
                string fileDir = Environment.CurrentDirectory + "\\Record\\";
                if (Directory.Exists(fileDir) == false)
                {
                    Directory.CreateDirectory(fileDir);
                }
                System.Diagnostics.Process.Start("explorer.exe", fileDir);
            }
            else
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "云端录制，文件保存在服务器上" });
            }
        }

        private void updateRecordContents(REC_CONTENT_TYPE state)
        {
            if (btnRecordOpr.IsEnabled == false)
                return;

            if (rbnLocal.IsChecked == true)
            {
                App.CRVideo.VideoSDK.updateLocMixerContent(mLocMixId, mixerContentsString(state));
            }
            else if (rbnCloud.IsChecked == true)
            {
                App.CRVideo.VideoSDK.updateCloudMixerContent(mCloudMixId, cloudMixerCfg());
            }
        }

        //更新视频录制配置信息
        private void LayoutChangeEvt_LayoutChanged()
        {
            //当前没有录制
            if (localRecordST==MIXER_STATE.MST_NULL && cloudRecordST==MIXER_STATE.MST_NULL)
                return;

            Console.WriteLine("LayoutChangeEvt_LayoutChanged:{0}", mLayoutChangeEvt.layoutCount);
            updateRecordContents(getRecContentType());
        }

        private void LayoutChangeEvt_VideoContentChanged()
        {
            //当前没有录制
            if (localRecordST == MIXER_STATE.MST_NULL && cloudRecordST == MIXER_STATE.MST_NULL)
                return;

            Console.WriteLine("LayoutChangeEvt_VideoContentChanged");
            updateRecordContents(getRecContentType());
        }

        private void LayoutChangeEvt_VideoRationChanged()
        {
            //当前没有录制
            if (localRecordST == MIXER_STATE.MST_NULL && cloudRecordST == MIXER_STATE.MST_NULL)
                return;

            Console.WriteLine("LayoutChangeEvt_VideoContentChanged");
            updateRecordContents(getRecContentType());
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if(!mbExit)
            {
                this.Hide();
                e.Cancel = true;
            }   
        }

         public void closeForm()
        {
            initDelegate(false);
            if (cloudRecordST!=MIXER_STATE.MST_NULL)
            {
                App.CRVideo.VideoSDK.destroyCloudMixer(mCloudMixId);
            }
            mbExit = true;
            this.Close();
        }        

        private string locMixerCfg()
        {
            LocMixerCfgObj _cfg = new LocMixerCfgObj();
            _cfg.width = getLayoutSize().Width;
            _cfg.height = getLayoutSize().Height;
            _cfg.frameRate = Int32.Parse(RecordFps.Text);
            _cfg.bitRate = Int32.Parse(RecordBps.Text);
            _cfg.defaultQP = mDefaultQP;
            _cfg.gop = 15 * _cfg.frameRate; //15秒一个I帧

            string str = JsonConvert.SerializeObject(_cfg);
            return str;
        }

        private System.Drawing.Size getLayoutSize()
        {
            System.Drawing.Size size = new System.Drawing.Size();
            if(layoutSize.SelectedIndex == 0)
            {
                size.Width = 640;   size.Height = 360;
            }
            else if(layoutSize.SelectedIndex == 1)
            {
                size.Width = 864;   size.Height = 480;
            }
            else if(layoutSize.SelectedIndex == 2)
            {
                size.Width = 1280;   size.Height = 720;
            }
            return size;
        }

        private string locMixoutput()
        {
            LocMixeroutputObjFile obj = new LocMixeroutputObjFile();
            //先开启录制，然后配置录制信息
            string recordFileName = DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss_Win32_") + Convert.ToString(Login.Instance.MeetID) + ".mp4";
     
            string recordDir = Environment.CurrentDirectory + "\\Record\\";
            if (Directory.Exists(recordDir) == false)
            {
                Directory.CreateDirectory(recordDir);
            }
            obj.filename = recordDir + recordFileName;
            obj.isUploadOnRecording = 0;
            obj.type = Convert.ToInt32(MIXER_OUTPUT_TYPE.MIXOT_FILE);

            List<LocMixeroutputObjFile> objlist = new List<LocMixeroutputObjFile>();
            objlist.Add(obj);
            string str = JsonConvert.SerializeObject(objlist);
            return str;
        }
           
        private string mixerContentsString(REC_CONTENT_TYPE type)
        {
            List<MixerContentObj> contentList = mixerContentList(type);
            string strContent = JsonConvert.SerializeObject(contentList);
            return strContent;
        }

        private List<MixerContentObj> mixerContentList(REC_CONTENT_TYPE type)
        {
            List<MixerContentObj> contentList = new List<MixerContentObj>();
            if (type == REC_CONTENT_TYPE.VIDEOWALL)
            {
                if (mLayoutChangeEvt.layoutCount > 0)
                {
                    List<RectangleF> vUIs = CRTools.getVideoUiRect(mLayoutChangeEvt.layoutCount, getLayoutSize().Width, getLayoutSize().Height, 10, 4, mLayoutChangeEvt.videoRation);
                    //添加需要录制的参与者                                                          
                    for (int i = 0; i < mLayoutChangeEvt.layoutCount; i++)
                    {
                        //添加摄像头
                        MixerContentObj mixcam = new MixerContentObj();
                        mixcam.type = Convert.ToInt32(MIXER_VCONTENT_TYPE.MIXVTP_VIDEO);
                        mixcam.left = (int)vUIs[i].Left;
                        mixcam.top = (int)vUIs[i].Top;
                        mixcam.width = (int)vUIs[i].Width;
                        mixcam.height = (int)vUIs[i].Height;
                        mixcam.keepAspectRatio = 1;
                        
                        paramCam camParam = new paramCam();
                        camParam.camid = "0.0";
                        if (i < mLayoutChangeEvt.videoUIs.Count) //有内容的视频
                        {
                            camParam.camid = String.Format("{0}.{1}", mLayoutChangeEvt.videoUIs[i].userID, mLayoutChangeEvt.videoUIs[i].camID);
                        }

                        mixcam.param = camParam;
                        contentList.Add(mixcam);
                    }
                }
            }
            else if(type == REC_CONTENT_TYPE.SCREEN)
            {
                MixerContentObj mixscreen = new MixerContentObj();
                mixscreen.left = 0;
                mixscreen.top = 0;
                mixscreen.width =  getLayoutSize().Width;
                mixscreen.height = getLayoutSize().Height;
                mixscreen.keepAspectRatio = 1;
                mixscreen.param = null;
                mixscreen.type = Convert.ToInt32(MIXER_VCONTENT_TYPE.MIXVTP_SCREEN_SHARED);
                contentList.Add(mixscreen);
            }
            else if (type == REC_CONTENT_TYPE.MEDIASHARE)
            {
                MixerContentObj mixscreen = new MixerContentObj();
                mixscreen.left = 0;
                mixscreen.top = 0;
                mixscreen.width = getLayoutSize().Width;
                mixscreen.height = getLayoutSize().Height;
                mixscreen.keepAspectRatio = 1;
                mixscreen.type = Convert.ToInt32(MIXER_VCONTENT_TYPE.MIXVTP_MEDIA);
                mixscreen.param = null;
                contentList.Add(mixscreen);
            }

            return contentList;
        }

        private string cloudMixerCfg()
        {
            string recordFileName = DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss") + "_Win32.mp4";
            string recordDir = "/" + recordFileName.Substring(0, 10) + "/";

            CloudMixerCfgObj cloudCfg = new CloudMixerCfgObj();
            cloudCfg.videoFileCfg = new CloudMixerVideoFileCfg();
            cloudCfg.videoFileCfg.svrPathName = recordDir + recordFileName;
            cloudCfg.videoFileCfg.vWidth = getLayoutSize().Width;
            cloudCfg.videoFileCfg.vHeight = getLayoutSize().Height;
            cloudCfg.videoFileCfg.vFps = Int32.Parse(RecordFps.Text);
            cloudCfg.videoFileCfg.vBps = Int32.Parse(RecordBps.Text);
            cloudCfg.videoFileCfg.vQP = mDefaultQP;
            cloudCfg.videoFileCfg.layoutConfig = mixerContentList(getRecContentType());

            string str = JsonConvert.SerializeObject(cloudCfg);
            return str;
        }

        private void localRecord()
        {
            if (localRecordST != MIXER_STATE.MST_NULL)
            {
                //停止录像
                App.CRVideo.VideoSDK.destroyLocMixer(mLocMixId);
            }
            else
            {
                label_record_desc.Text = "";

                //先开启录制
                int nRet = App.CRVideo.VideoSDK.createLocMixer(mLocMixId, locMixerCfg(), mixerContentsString(getRecContentType()));
                if (nRet != 0)
                {
                    Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "录制发生错误，代码：" + CRError.Instance.getError(nRet) });
                    return ;
                }

                //然后添加输出录制文件
                nRet = App.CRVideo.VideoSDK.addLocMixerOutput(mLocMixId, locMixoutput());
                if(nRet != 0)
                {
                    App.CRVideo.VideoSDK.destroyLocMixer(mLocMixId);
                    Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "录制发生错误，代码：" + CRError.Instance.getError(nRet) });
                    return;
                }
            }
        }

        private void cloudRecord()
        {
            if (cloudRecordST != MIXER_STATE.MST_NULL)
            {
                App.CRVideo.VideoSDK.destroyCloudMixer(mCloudMixId);
            }
            else
            {
                label_record_desc.Text = "";

                mCloudMixId = App.CRVideo.VideoSDK.createCloudMixer(cloudMixerCfg());
            }
        }
 
        REC_CONTENT_TYPE getRecContentType()
        {
            return recordContent;
        }

        private void startScreenShareRslt(object sender, ICloudroomVideoSDKEvents_startScreenShareRsltEvent e)
        {
            if(e.p_sdkErr == 0)
            {
                recordContent = REC_CONTENT_TYPE.SCREEN;
                updateRecordContents(getRecContentType());
            }
        }
        private void stopScreenShareRslt(object sender, ICloudroomVideoSDKEvents_stopScreenShareRsltEvent e)
        {
            recordContent = REC_CONTENT_TYPE.VIDEOWALL;
            updateRecordContents(getRecContentType());
        }
        private void notifyScreenShareStarted(object sender, ICloudroomVideoSDKEvents_notifyScreenShareStartedEvent e)
        {
            recordContent = REC_CONTENT_TYPE.SCREEN;
            updateRecordContents(getRecContentType());

        }
        private void notifyScreenShareStopped(object sender, EventArgs e)
        {
            recordContent = REC_CONTENT_TYPE.VIDEOWALL;
            updateRecordContents(getRecContentType());
        }
        private void notifyMediaStart(object sender, ICloudroomVideoSDKEvents_notifyMediaStartEvent e)
        {
            recordContent = REC_CONTENT_TYPE.MEDIASHARE;
            updateRecordContents(getRecContentType());

        }
        private void notifyMediaStop(object sender, ICloudroomVideoSDKEvents_notifyMediaStopEvent e)
        {
            recordContent = REC_CONTENT_TYPE.VIDEOWALL;
            updateRecordContents(getRecContentType());

        }

        private void RecordFps_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            TextBox tb = (TextBox)sender;
            Regex re = new Regex("[^0-9]+");
            bool yes = re.IsMatch(e.Text);
            
            e.Handled = yes;
        }

        private void RecordBps_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            TextBox tb = (TextBox)sender;
            Regex re = new Regex("[^0-9]+");
            bool yes = re.IsMatch(e.Text);

            e.Handled = yes;
        }

        private void layoutSize_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if(layoutSize.SelectedIndex == 0)
            {
                RecordBps.Text = "350000";
            }
            else if(layoutSize.SelectedIndex == 1)
            {
                RecordBps.Text = "1000000";

            }
            else if(layoutSize.SelectedIndex == 2)
            {
                RecordBps.Text = "2000000";

            }
        }
    }
}
