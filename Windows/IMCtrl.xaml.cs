using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Newtonsoft.Json;
using AxnpcloudroomvideosdkLib;

namespace SDKDemo
{
    /// <summary>
    /// IMCtrl.xaml 的交互逻辑
    /// </summary>
    /// 
    public partial class IMCtrl : UserControl
    {
        public struct IMType
        {
            public string CmdType;
            public string IMMsg;
        }
        public IMCtrl()
        {
            InitializeComponent();

            App.CRVideo.VideoSDK.sendMeetingCustomMsgRslt += sendMeetingCustomMsgRslt;
            App.CRVideo.VideoSDK.notifyMeetingCustomMsg += notifyMeetingCustomMsg;
        }

        
        public void unInitPage()
        {
            App.CRVideo.VideoSDK.sendMeetingCustomMsgRslt -= sendMeetingCustomMsgRslt;
            App.CRVideo.VideoSDK.notifyMeetingCustomMsg -= notifyMeetingCustomMsg;
        }

        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { MessageBox.Show(desc); }

        private void sendMeetingCustomMsgRslt(object sender, ICloudroomVideoSDKEvents_sendMeetingCustomMsgRsltEvent e)
        {
            if (e.p_sdkErr != 0)
            {
                Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "消息发送失败:" + CRError.Instance.getError(e.p_sdkErr) });
            }
            else
            {
                txtMsg.Clear();
            }
        }

        private void notifyMeetingCustomMsg(object sender, ICloudroomVideoSDKEvents_notifyMeetingCustomMsgEvent e)
        {
            //int to time
            string msg = e.p_jsonDat;
            if(!string.IsNullOrEmpty(msg))
            {
                try
                {
                    IMType type = JsonConvert.DeserializeObject<IMType>(msg);
                    if (type.CmdType == "IM")
                    {
                        msg = type.IMMsg;
                    }
                }
                catch(Exception ex)
                {

                }
              
            }
            if (e.p_fromUserID != Login.Instance.myUserID) //自己对自己广播
            {
                string fromUsrName = App.CRVideo.VideoSDK.getMemberNickName(e.p_fromUserID);
                string msgMe = "[" + fromUsrName + "]  " + "\n " + msg + "\n";
                chatText.AppendText(msgMe);
            }
            else
            {
                string msgOther = String.Format("[我]\n ") + msg + "\n";
                chatText.AppendText(msgOther);
            }

            chatText.ScrollToEnd();
        }

        private void btnSend_Click(object sender, RoutedEventArgs e)
        {
            if (txtMsg.Text.Trim() == "")
            {
                MessageBox.Show("不允许发送空消息");
                return;
            }
            //广播消息到会议内
            IMType type;
            type.CmdType = "IM";
            type.IMMsg = txtMsg.Text;
            string ss = JsonConvert.SerializeObject(type);
            App.CRVideo.VideoSDK.sendMeetingCustomMsg(ss, "");
        }

        private Dictionary<string, string> mNickName2UserID = new Dictionary<string, string>();
      
    }
    
}
