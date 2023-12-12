using System;
using System.Windows;
using AxnpcloudroomvideosdkLib;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.ComponentModel;
using System.Collections.ObjectModel;
using System.Timers;


namespace SDKDemo
{
    public class inviteInfo : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public inviteInfo(string inviteID_t, string inviteeUsrID_t, STATE state_t)
        {
            inviteID = inviteID_t;
            inviteeUsrID = inviteeUsrID_t;
            setState(state_t);
        }
        public string inviteID { set; get; }
        public string inviteeUsrID { set; get; }

        public enum STATE
        {
            INVITEFAIL,
            INVITESUC,
            CANCELED_SYS,
            CANCELED_USR,
            RJECTED_SYS,
            RJECTED_USR,
            RJECTED_Meeting,
            ACCEPED
        };

        public string visible { set; get; }
        public string stateDesc { set; get; }
        public STATE state
        {
            set
            {
                mState = value;
                setState(value);
                PropertyChanged.Invoke(this, new PropertyChangedEventArgs("visible"));
                PropertyChanged.Invoke(this, new PropertyChangedEventArgs("stateDesc"));
            }
            get
            {
                return mState;
            }
        }

        private STATE mState;
        private void setState(STATE value)
        {
            visible = (value == STATE.INVITESUC) ? "Visible" : "Collapsed";

            switch (value)
            {
                case STATE.INVITESUC:
                    stateDesc = "邀请发送成功，等待对方应答中";
                    break;
                case STATE.INVITEFAIL:
                    stateDesc = "邀请发送失败";
                    break;
                case STATE.CANCELED_USR:
                    stateDesc = "邀请已被取消";
                    break;
                case STATE.RJECTED_SYS:
                    stateDesc = "邀请超时无应答,被拒绝";
                    break;
                case STATE.RJECTED_USR:
                    stateDesc = "邀请被对方主动拒绝";
                    break;
                case STATE.RJECTED_Meeting:
                    stateDesc = "邀请被拒绝，对方在会议中";
                    break;
                case STATE.ACCEPED:
                    stateDesc = "邀请被对方接受";
                    break;
            }
        }
    }
    /// <summary>
    /// Invite.xaml 的交互逻辑
    /// </summary>
    /// 
    public partial class Invite : Window
    {
       
        private ObservableCollection<inviteInfo> m_list_invites = new ObservableCollection<inviteInfo>();
        private string m_inviteID;
        private System.Timers.Timer m_timer;
        public enum RST { 
            ACCEPTED,
            REJECTED,
            CANCELED
        }
        public Invite(bool isInvited)
        {
            InitializeComponent();
            initDelegate(true);

            if (isInvited)
            {
                tabControl.SelectedItem = tbItem_userCall;    //被邀请
            }
            else
            {
                tabControl.SelectedItem = tbItem_callUser;    //邀请他人
            }
            listView_invite.ItemsSource = m_list_invites;

        }

        public void initDelegate(bool isInit)
        {
            if (isInit)
            {
                App.CRVideo.VideoSDK.inviteSuccess +=        inviteSuccess;
                App.CRVideo.VideoSDK.inviteFail +=           inviteFail;
                App.CRVideo.VideoSDK.acceptInviteSuccess +=  acceptInviteSuccess;
                App.CRVideo.VideoSDK.acceptInviteFail +=     acceptInviteFail;
                App.CRVideo.VideoSDK.cancelInviteSuccess +=  cancelInviteSuccess;
                App.CRVideo.VideoSDK.cancelInviteFail +=     cancelInviteFail;
                App.CRVideo.VideoSDK.rejectInviteSuccess +=  rejectInviteSuccess;
                App.CRVideo.VideoSDK.rejectInviteFail +=     rejectInviteFail;

                App.CRVideo.VideoSDK.notifyInviteAccepted += notifyInviteAccepted;
                App.CRVideo.VideoSDK.notifyInviteCanceled += notifyInviteCanceled;
                App.CRVideo.VideoSDK.notifyInviteRejected += notifyInviteRejected;
            }
            else
            {
                App.CRVideo.VideoSDK.inviteSuccess -= inviteSuccess;
                App.CRVideo.VideoSDK.inviteFail -= inviteFail;
                App.CRVideo.VideoSDK.acceptInviteSuccess -= acceptInviteSuccess;
                App.CRVideo.VideoSDK.acceptInviteFail -= acceptInviteFail;
                App.CRVideo.VideoSDK.cancelInviteSuccess -= cancelInviteSuccess;
                App.CRVideo.VideoSDK.cancelInviteFail -= cancelInviteFail;
                App.CRVideo.VideoSDK.rejectInviteSuccess -= rejectInviteSuccess;
                App.CRVideo.VideoSDK.rejectInviteFail -= rejectInviteFail;

                App.CRVideo.VideoSDK.notifyInviteAccepted -= notifyInviteAccepted;
                App.CRVideo.VideoSDK.notifyInviteCanceled -= notifyInviteCanceled;
                App.CRVideo.VideoSDK.notifyInviteRejected -= notifyInviteRejected;
            }
        }

      
        public void setInviteMsg(string inviterUsrID, string inviteID)
        {
            tb_msg.Text = inviterUsrID + "正在邀请你";
            m_inviteID = inviteID;
            btnReceive.Visibility = Visibility.Visible;
            btnReject.Visibility = Visibility.Visible;
        }
        private void btnInvite_Click(object sender, RoutedEventArgs e)
        {
            string inviteeUsrID = edt_UserID.Text.Trim();
            if (string.IsNullOrEmpty(inviteeUsrID))
            {
                MessageBox.Show("请输入被邀请对象的用户ID");
                return;
            }

            for (int i = 0; i < m_list_invites.Count; i ++ )
            {
                if (m_list_invites[i].inviteeUsrID == inviteeUsrID && m_list_invites[i].state == inviteInfo.STATE.INVITESUC)
                {
                    MessageBox.Show("您正在邀请此对象!");
                    return;
                }
            }

            InviteMeetInfo ivInfo = new InviteMeetInfo();
            ivInfo.meeting = new MeetInfo();
            ivInfo.meeting.ID = Login.Instance.MeetID;
            string usrExtDat = JsonConvert.SerializeObject(ivInfo);
            string inviteID = App.CRVideo.VideoSDK.invite(inviteeUsrID, usrExtDat, inviteeUsrID);
        }

        private void inviteSuccess(object sender, ICloudroomVideoSDKEvents_inviteSuccessEvent e)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
            this.Dispatcher.BeginInvoke((Action)delegate() {
                m_list_invites.Add(new inviteInfo(e.p_inviteID,e.p_cookie,inviteInfo.STATE.INVITESUC));            
            });
        }

        private void inviteFail(object sender, ICloudroomVideoSDKEvents_inviteFailEvent e)
        {
             this.Dispatcher.BeginInvoke((Action)delegate() {
                 m_list_invites.Add(new inviteInfo(e.p_inviteID, e.p_cookie, inviteInfo.STATE.INVITEFAIL)); 
             });
        }

        private void acceptInviteSuccess(object sender, ICloudroomVideoSDKEvents_acceptInviteSuccessEvent e)
        {
            if (m_inviteID != e.p_inviteID)
                return;

            this.DialogResult = true;
            Close();
        }

        private void acceptInviteFail(object sender, ICloudroomVideoSDKEvents_acceptInviteFailEvent e)
        {
            if (m_inviteID != e.p_inviteID)
                return;

            tb_tip.Text = "接受邀请失败";
        }

        private void cancelInviteSuccess(object sender, ICloudroomVideoSDKEvents_cancelInviteSuccessEvent e)
        {
            for (int i = 0; i < m_list_invites.Count; i ++ )
            {
                if(m_list_invites[i].inviteID == e.p_inviteID)
                {
                    m_list_invites[i].state = inviteInfo.STATE.CANCELED_USR;
                    break;
                }
            }
        }

        private void cancelInviteFail(object sender, ICloudroomVideoSDKEvents_cancelInviteFailEvent e)
        {
            //---
        }

        private void rejectInviteSuccess(object sender, ICloudroomVideoSDKEvents_rejectInviteSuccessEvent e)
        {
            if (m_inviteID != e.p_inviteID)
                return;
            this.DialogResult = false;

            Close();
        }

        private void rejectInviteFail(object sender, ICloudroomVideoSDKEvents_rejectInviteFailEvent e)
        {
            if (m_inviteID != e.p_inviteID)
                return;
            tb_tip.Text = "拒绝邀请失败";
        }

        private void notifyInviteAccepted(object sender, ICloudroomVideoSDKEvents_notifyInviteAcceptedEvent e)
        {
            for (int i = 0; i < m_list_invites.Count; i++)
            {
                if (m_list_invites[i].inviteID == e.p_inviteID)
                {
                    m_list_invites[i].state = inviteInfo.STATE.ACCEPED;
                    break;
                }
            }
            
        }
        private void notifyInviteCanceled(object sender, ICloudroomVideoSDKEvents_notifyInviteCanceledEvent e)
        {
            if (m_inviteID != e.p_inviteID)
                return;

            if(e.p_reason == 0)
            {
                tb_tip.Text = "邀请已经被对方取消";
            }
            else
            {
                tb_tip.Text = "超时无应答，邀请已被取消";
            }
            btnReceive.Visibility = System.Windows.Visibility.Hidden;
            btnReject.Visibility = System.Windows.Visibility.Hidden;
            m_timer = new System.Timers.Timer();
            m_timer.AutoReset = false;
            m_timer.Elapsed += new System.Timers.ElapsedEventHandler(closeWnd);
            m_timer.Interval = 3000;
            //m_timer.Enabled = true;
            m_timer.Start();
        }

        private void closeWnd (object sender_t, ElapsedEventArgs e_t)
        {
            this.Dispatcher.BeginInvoke((Action)delegate()
            {
                this.DialogResult = false;
                Close();
            });
            
        } 
        private void notifyInviteRejected(object sender, ICloudroomVideoSDKEvents_notifyInviteRejectedEvent e)
        {
            for (int i = 0; i < m_list_invites.Count; i++)
            {
                if (m_list_invites[i].inviteID == e.p_inviteID)
                {
                    if (e.p_reason == 0)
                    {
                        if(e.p_usrExtDat == "Meeting")
                        {
                            m_list_invites[i].state = inviteInfo.STATE.RJECTED_Meeting;
                        }
                        else
                        {
                            m_list_invites[i].state = inviteInfo.STATE.RJECTED_USR;
                        }
                    }
                    else
                    {
                        m_list_invites[i].state = inviteInfo.STATE.RJECTED_SYS;
                    }
                    break;
                }
            }
        }
       
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            initDelegate(false);
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            string inviteID = ((System.Windows.Controls.Button)sender).CommandParameter.ToString();
            App.CRVideo.VideoSDK.cancelInvite(inviteID, "", "");
        }

        private void btnReceive_Click(object sender, RoutedEventArgs e)
        {
            App.CRVideo.VideoSDK.acceptInvite(m_inviteID, "", "");
        }

        private void btnReject_Click(object sender, RoutedEventArgs e)
        {
            App.CRVideo.VideoSDK.rejectInvite(m_inviteID, "", "");

        }

    }
}
