using System;
using System.Text;
using System.Windows;
using System.IO;
using System.Windows.Forms;
using AxnpcloudroomvideosdkLib;
using Newtonsoft.Json;

namespace SDKDemo
{
    /// <summary>
    /// StartMeetingWin.xaml 的交互逻辑
    /// </summary>
    public partial class StartMeetingWin : Window
    {
        public struct IMType
        {
            public string CmdType;
            public string IMMsg;
        }
        private string mNickName;       
        private Invite mInvite = null;        
        private MeetingMainWin meetingMainWin = null;
        private updateToken tokenUI = null;
        public StartMeetingWin(Window parent, string nickName)
        {
            InitializeComponent();
            this.Owner = parent;
            this.Owner.ShowInTaskbar = false;

            initDelegate(true);            

            mNickName = nickName;

            tb_loginInfo.Text = "欢迎 " + mNickName + " ...";

            IniFile iniFile = new IniFile(Directory.GetCurrentDirectory() + "/meeting.ini");
            edt_MeetID.Text = iniFile.ReadValue("Cfg", "lastMeetingID", "");
        }

        private void initDelegate( bool isInit)
        {
            if(isInit)
            {
                App.CRVideo.VideoSDK.meetingStopped += Meeting_meetingStopped;
                App.CRVideo.VideoSDK.meetingDropped += meetingDropped;
                App.CRVideo.VideoSDK.lineOff += lineOff;
                App.CRVideo.VideoSDK.enterMeetingRslt += enterMeetingRslt;
                App.CRVideo.VideoSDK.createMeetingSuccess += createMeetingSuccess;
                App.CRVideo.VideoSDK.createMeetingFail += createMeetingFailed;
                App.CRVideo.VideoSDK.sendFileRlst += sendFileRlst;
                App.CRVideo.VideoSDK.notifyFileData += notifyFileData;
                App.CRVideo.VideoSDK.cancelSendRlst += cancelSendRlst;
                App.CRVideo.VideoSDK.sendProgress += sendProgress;
                App.CRVideo.VideoSDK.sendCmdRlst += sendCmdRlst;
                App.CRVideo.VideoSDK.notifyCmdData += notifyCmdData;
                App.CRVideo.VideoSDK.notifyInviteIn += notifyInviteIn;

                App.CRVideo.VideoSDK.notifyTokenWillExpire += notifyTokenWillExpire;
            }
            else 
            {
                App.CRVideo.VideoSDK.meetingStopped -= Meeting_meetingStopped;
                App.CRVideo.VideoSDK.meetingDropped -= meetingDropped;
                App.CRVideo.VideoSDK.lineOff -= lineOff;
                App.CRVideo.VideoSDK.enterMeetingRslt -= enterMeetingRslt;
                App.CRVideo.VideoSDK.createMeetingSuccess -= createMeetingSuccess;
                App.CRVideo.VideoSDK.createMeetingFail -= createMeetingFailed;
                App.CRVideo.VideoSDK.sendFileRlst -= sendFileRlst;
                App.CRVideo.VideoSDK.notifyFileData -= notifyFileData;
                App.CRVideo.VideoSDK.cancelSendRlst -= cancelSendRlst;
                App.CRVideo.VideoSDK.sendProgress -= sendProgress;
                App.CRVideo.VideoSDK.sendCmdRlst -= sendCmdRlst;
                App.CRVideo.VideoSDK.notifyCmdData -= notifyCmdData;
                App.CRVideo.VideoSDK.notifyInviteIn -= notifyInviteIn;
                App.CRVideo.VideoSDK.notifyTokenWillExpire -= notifyTokenWillExpire;
            }
        }

        //服务端消息处理使用异步消息弹框，防止阻塞对服务器的响应
        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { System.Windows.MessageBox.Show(this, desc); }
        private void TokenMsgBox(string desc) {
            if (tokenUI == null)
                tokenUI = new updateToken();
            
            tokenUI.Show(); 
        }

        private void Window_Closed(object sender, EventArgs e)
        {
            if (tokenUI != null)
                tokenUI.Close();
            tokenUI = null;

            initDelegate(false);
            Login.Instance.logout();
        }

        private void btnEnterMeeting_Click(object sender, RoutedEventArgs e)
        {
            CreateMeet(); 
        }

        //创建会议
        private void CreateMeet()
        {
            btnEnterMeeting.IsEnabled = false;
            App.CRVideo.VideoSDK.createMeeting2("", "");
        }

        private void createMeetingSuccess(object sender, ICloudroomVideoSDKEvents_createMeetingSuccessEvent e)
        {
            Console.WriteLine("create meeting succeed...");

            MeetObj meet = JsonConvert.DeserializeObject<MeetObj>(e.p_meetObj);
            EnterMeeting(meet.ID);
        }

        private void createMeetingFailed(object sender, ICloudroomVideoSDKEvents_createMeetingFailEvent e)
        {
            btnEnterMeeting.IsEnabled = true;
            Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "创建会议失败，代码：" + CRError.Instance.getError(e.p_sdkErr) });
        }

        private bool stringToNumber(string source, ref int result)
        {
            try
            {
                result = Convert.ToInt32(source);
                return true;
            }
            catch (System.Exception ex)
            {
                Console.WriteLine("stringToNumber:" + ex.Message);
                result = 0;
                return false;
            }
        }

        private void btnEnterMeetByID_Click(object sender, RoutedEventArgs e)
        {
            if (edt_MeetID.Text.Trim() == "")
            {
                System.Windows.MessageBox.Show("请输入会议号");
                return;
            }

            if (edt_MeetID.Text.Length != 8)
            {
                System.Windows.MessageBox.Show("会议号位数错误");
                return;
            }
            int meetID = 0;
            if (!stringToNumber(edt_MeetID.Text, ref meetID))
            {
                System.Windows.MessageBox.Show("会议号只能输入数字，请检查");
                return;
            }
            btnEnterMeetByID.IsEnabled = false;            

            EnterMeeting(meetID);
        }

        private void EnterMeeting(int meetID)
        {
            Console.WriteLine("enter meeting:{0} ...", meetID);
            Login.Instance.MeetID = meetID;
            edt_MeetID.Text = meetID.ToString();
            IniFile iniFile = new IniFile(Directory.GetCurrentDirectory() + "/meeting.ini");
            iniFile.WriteValue("Cfg", "lastMeetingID", edt_MeetID.Text);

            meetingMainWin = new MeetingMainWin(this);//创建会议主窗体
            App.CRVideo.VideoSDK.enterMeeting3(meetID);
        }

        //入会结果
        private void enterMeetingRslt(object sender, ICloudroomVideoSDKEvents_enterMeetingRsltEvent e)
        {
            if (meetingMainWin == null) //进入会议可能接收到下线消息销毁窗口 在此做判断保护
                return;

            if (e.p_sdkErr != (int)VCALLSDK_ERR_DEF.VCALLSDK_NOERR)
            {
                meetingMainWin.mIsSelfClose = false;
                meetingMainWin.Close();
                meetingMainWin = null;
                Console.WriteLine("enterMeetingRslt:" + e.p_sdkErr);
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "入会失败，请重试，代码：" + CRError.Instance.getError(e.p_sdkErr) });
            }
            else
            {
                try
                {
                    App.CRVideo.VideoSDK.setEnableMutiVideo(Login.Instance.myUserID, 0);
                    this.Visibility = Visibility.Hidden;                        
                    meetingMainWin.initMeeting(Login.Instance.MeetID); //入会成功，显示会议主窗体                    
                    meetingMainWin.Owner = this;                    

                    meetingMainWin.Show();
                }
                catch (System.Exception ex)
                {
                    this.Visibility = Visibility.Visible;
                    Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "创建会议主窗体发生异常:\n" + ex.ToString() + CRError.Instance.getError(e.p_sdkErr) });
                }
            }
            btnEnterMeeting.IsEnabled = true;
            btnEnterMeetByID.IsEnabled = true;
        }

        private void btnLogout_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("logout~~~~~");                       

            txtSelectedFile.Text = "";
            mSelectedFile = "";
            mBufferTaskID = "";

            this.Close();
        }

        private string mBufferTaskID = "";

        private void btnSendFile_Click(object sender, RoutedEventArgs e)
        {
            if (mBufferTaskID != "")
            {
                App.CRVideo.VideoSDK.cancelSend(mBufferTaskID);
                label_sendBuffer_desc.Text = "发送已取消";
            }
            else
            {
                sendFileBuffer();
            }
        }

        private void notifyTokenWillExpire(object sender, EventArgs e)
        {
            Dispatcher.BeginInvoke(new messageBoxDelegate(TokenMsgBox), new object[] { "令牌即将失效, 是否更新令牌!" });
        }
        private void btnSendCmd_Click(object sender, RoutedEventArgs e)
        {
            if (txtCmdData.Text.Trim() == "")
            {
                System.Windows.MessageBox.Show(this, "请输入要发送的数据");
                return;
            }
            if (txtCmdReceiver.Text.Trim() == "")
            {
                System.Windows.MessageBox.Show(this, "请输入数据接收者的ID");
                return;
            }

            IMType type;
            type.CmdType = "IM";
            type.IMMsg = txtCmdData.Text.Trim();
            string ss = JsonConvert.SerializeObject(type);
            App.CRVideo.VideoSDK.sendCmd(txtCmdReceiver.Text.Trim(), ss);
            GC.Collect();
        }

        private void sendFileBuffer()
        {
            if (txtSelectedFile.Text == "")
            {
                System.Windows.MessageBox.Show("请选择需要发送的文件");
                return;
            }
            if (txtFileReceiver.Text == "")
            {
                System.Windows.MessageBox.Show("请添加文件接收者");
                return;
            }

            using (FileStream stream = new FileInfo(mSelectedFile).OpenRead())
            {
                label_sendBuffer_desc.Text = "文件大小：" + stream.Length / 1024 + "KB";
            }            
            
            mBufferTaskID = (string)App.CRVideo.VideoSDK.sendFile(txtFileReceiver.Text.Trim(), mSelectedFile);
        }

        private void sendProgress(object sender, ICloudroomVideoSDKEvents_sendProgressEvent e)
        {
            Console.WriteLine("sendBufferProgress:" + e.p_totalLen + "->" + e.p_sendedLen);

            label_sendBuffer_desc.Text = "总大小：" + e.p_totalLen + ", 已发送" + e.p_sendedLen;

            if (mBufferTaskID != "")
            {
                btnSendFile.Content = "取消发送 ";
            }

            //发完了，清空本次发送信息
            if (e.p_sendedLen == e.p_totalLen)
            {
                mBufferTaskID = "";
                btnSendFile.Content = "发送文件 ";
                label_sendBuffer_desc.Text = "发送成功";

                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "发送成功" });
            }
        }

        //测试文件数据
        private string mSelectedFile;

        private void btnSelectFile_Click(object sender, EventArgs e)
        {
            OpenFileDialog openDlg = new OpenFileDialog();
            openDlg.Filter = "All files (*.*)|*.*";
            openDlg.RestoreDirectory = true;
            if (openDlg.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                mSelectedFile = openDlg.FileName;
            }
            else
            {
                mSelectedFile = "";
            }

            txtSelectedFile.Text = mSelectedFile;
            txtSelectedFile.IsReadOnly = true;
        }

        private void cancelSendRlst(object sender, ICloudroomVideoSDKEvents_cancelSendRlstEvent e)
        {
            if (e.p_sdkErr > 0)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "取消发送失败" + CRError.Instance.getError(e.p_sdkErr) });
            }
            else
            {
                btnSendFile.Content = "发送文件";
                mBufferTaskID = "";
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "取消发送成功" });
            }
        }

        private void sendCmdRlst(object sender, ICloudroomVideoSDKEvents_sendCmdRlstEvent e)
        {
            if (e.p_sdkErr > 0)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "发送命令数据失败，代码：" + CRError.Instance.getError(e.p_sdkErr) });
            }
            else
            {
                if (mBufferTaskID != "")
                {
                    btnSendCmd.Content = "取消发送";
                }
            }
        }

        private void notifyCmdData(object sender, ICloudroomVideoSDKEvents_notifyCmdDataEvent e)
        {
            string msg = e.p_data;
            if (!string.IsNullOrEmpty(msg))
            {
                try
                {
                    IMType type = JsonConvert.DeserializeObject<IMType>(msg);
                    if (type.CmdType == "IM")
                    {
                        msg = type.IMMsg;
                        Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "来自[" + e.p_sourceUserId + "]的命令数据:\n\n" + msg });
                    }
                }
                catch (Exception ex)
                {

                }

            }
        }


        private void notifyInviteIn(object sender, ICloudroomVideoSDKEvents_notifyInviteInEvent e)
        {
            if (this.Visibility != Visibility.Visible)
            {
                App.CRVideo.VideoSDK.rejectInvite(e.p_inviteID, "Meeting", "");
                return;
            }
            mInvite = new Invite(true);
            mInvite.setInviteMsg(e.p_inviterUsrID, e.p_inviteID);

            if (mInvite.ShowDialog() == true)
            {
                InviteMeetInfo iv = JsonConvert.DeserializeObject<InviteMeetInfo>(e.p_usrExtDat);

                EnterMeeting(iv.meeting.ID);
            }
         
        }

        private void sendFileRlst(object sender, ICloudroomVideoSDKEvents_sendFileRlstEvent e)
        {
            if (e.p_sdkErr != 0)
            {
                mBufferTaskID = "";
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "发送失败，代码：" + CRError.Instance.getError(e.p_sdkErr) });
            }
        }

        private void notifyFileData(object sender, ICloudroomVideoSDKEvents_notifyFileDataEvent e)
        {
            Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "收到" + e.p_sourceUserId + "发来的文件：\n" + e.p_orgFileName + "\n临时存放位置：" + e.p_tmpFile + "" });
        }

        private void Meeting_meetingStopped(object sender, EventArgs e)
        {
            if (meetingMainWin != null)
            {
                meetingMainWin.mIsSelfClose = false;
                meetingMainWin.Close();
                meetingMainWin = null;

                System.Windows.MessageBox.Show(this, "会议已结束", "提示", MessageBoxButton.OK);
            }
        }

        private void meetingDropped(object sender, ICloudroomVideoSDKEvents_meetingDroppedEvent e)
        {
            if (meetingMainWin != null)
            {
                meetingMainWin.mIsSelfClose = false;
                meetingMainWin.Close();
                meetingMainWin = null;

                if (e.p_reason == (int)CRVIDEOSDK_MEETING_DROPPED_REASON.CRVIDEOSDK_DROPPED_KICKOUT)
                {
                    System.Windows.MessageBox.Show(this, "您被请出了会议。", "提示", MessageBoxButton.OK);
                }
                else
                {
                    System.Windows.MessageBox.Show(this, "会议已掉线，请重新进入", "掉线", MessageBoxButton.OK);
                }
            }
        }

        private void lineOff(object sender, ICloudroomVideoSDKEvents_lineOffEvent e)
        {
            if (tokenUI != null)
                tokenUI.Close();
            tokenUI = null;

            if (meetingMainWin != null)
            {
                meetingMainWin.mIsSelfClose = false;
                meetingMainWin.Close();
                meetingMainWin = null;
            }

            if (e.p_sdkErr == (int)VCALLSDK_ERR_DEF.VCALLSDK_USER_BEEN_KICKOUT)
            {
                System.Windows.MessageBox.Show(this, "您被挤掉线，请检查昵称重新登陆", "掉线", MessageBoxButton.OK);
            }
            else if (e.p_sdkErr == (int)VCALLSDK_ERR_DEF.VCALLSDK_TOKEN_AUTHINFOTIMEOUT)
            {
                System.Windows.MessageBox.Show(this, "令牌失效", "掉线", MessageBoxButton.OK);
            }
            else if ((e.p_sdkErr >= (int)VCALLSDK_ERR_DEF.VCALLSDK_TOKEN_AUTHINFOERR) && (e.p_sdkErr <= (int)VCALLSDK_ERR_DEF.VCALLSDK_TOKEN_APPIDNOTSAME))
            {
                System.Windows.MessageBox.Show(this, "令牌鉴权失败", "掉线", MessageBoxButton.OK);

            }
            else
            {
                System.Windows.MessageBox.Show(this, "您已掉线，请重新登陆", "掉线", MessageBoxButton.OK);
          //      Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "您已掉线，请重新登陆" });
            }

            
            mSelectedFile = "";
            mBufferTaskID = "";

            this.Close();
        }

        private void initQueueDatRslt(object sender, ICloudroomVideoSDKEvents_initQueueDatRsltEvent e)
        {
            if (e.p_sdkErr != 0)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "队列初始化失败，代码" + CRError.Instance.getError(e.p_sdkErr) });
            }
        }
    }
}
