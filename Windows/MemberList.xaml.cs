using AxnpcloudroomvideosdkLib;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
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

namespace Meeting_WPF
{
    /// <summary>
    /// MemberList.xaml 的交互逻辑
    /// </summary>
    /// 
    public class MemInfo : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public MemInfo(string usrID, string nickName, bool bAudio, bool bVideo)
        {
            UsrID = usrID;
            showName = nickName;
            bOpenAudio = bAudio;
            bOpenVideo = bVideo;

        }

        public string UsrID { get; set; }
        public string showName { get; set; }
        public string Name
        {
            set
            {
                showName = value;
                if(PropertyChanged != null)
                {
                    PropertyChanged.Invoke(this, new PropertyChangedEventArgs("showName"));
                }
            }
            get
            {
                return showName;
            }
        }

        public string audioImg { get; set; }

        public string videoImg { get; set; }

        public bool mbOpenAudio;
        public bool bOpenAudio
        {
            set {
                mbOpenAudio = value;
                if (value)
                    audioImg = "/Res/mic_open.png";
                else
                    audioImg = "/Res/mic_mute.png";

                if (PropertyChanged != null)
                {
                    PropertyChanged.Invoke(this, new PropertyChangedEventArgs("audioImg"));
                }
            }
            get
            {
                return mbOpenAudio;
            }
        }

        public int energyLevel
        {
            set
            {
                if (value == 0)
                    audioImg = "/Res/mic_open.png";
                else if(value <= 3)
                    audioImg = "/Res/speak1.png";
                else if (value <= 6)
                    audioImg = "/Res/speak2.png";
                else
                    audioImg = "/Res/speak3.png";

                if (PropertyChanged != null)
                {
                    PropertyChanged.Invoke(this, new PropertyChangedEventArgs("audioImg"));
                }
            }
        }

        public bool mbOpenVideo;
        public bool bOpenVideo
        {
            set {
                
                mbOpenVideo = value;
                if (value)
                    videoImg = "/Res/video_open.png";
                else
                    videoImg = "/Res/video_close.png";

                if (PropertyChanged != null)
                {
                    PropertyChanged.Invoke(this, new PropertyChangedEventArgs("videoImg"));
                }

            }
            get{
                return mbOpenVideo;
            }
        }
     
    }
 
    public partial class MemberList : UserControl
    {
        private ObservableCollection<MemInfo> m_membersList;
       
        public MemberList()
        {
            InitializeComponent();

            m_membersList = new ObservableCollection<MemInfo>();
            memList.ItemsSource = m_membersList;
            initDelegate(true);
        }

        public void initDelegate(bool bInit)
        {
            if(bInit)
            {
                App.CRVideo.VideoSDK.setNickNameRsp += setNickNameRsp;
                App.CRVideo.VideoSDK.notifyNickNameChanged += notifyNickNameChanged;
            }
            else
            {
                App.CRVideo.VideoSDK.setNickNameRsp -= setNickNameRsp;
                App.CRVideo.VideoSDK.notifyNickNameChanged -= notifyNickNameChanged;
            }
        }
        private MemInfo findMember(string usrID)
        {
            for (int i = 0; i < m_membersList.Count; i++)
            {
                if (m_membersList[i].UsrID == usrID)
                {
                    return m_membersList[i];
                }
            }
            return null;
        }
        public void addMember(string usrID, string nickName, bool bMicOpen = false, bool bVideoOpen = false)
        {
            m_membersList.Add(new MemInfo(usrID, nickName, bMicOpen, bVideoOpen));
        }

        public void removeMember(string usrID)
        {
            MemInfo info = findMember(usrID);
            if(info != null)
            {
                m_membersList.Remove(info);
            }
        }

        public void ChangeMemberNickName(string nickName, string changedNickName)
        {
            
        }
        public void setMicStatus(string usrID, bool bMicOpen)
        {
            MemInfo info = findMember(usrID);
            if (info != null)
            {
                info.bOpenAudio = bMicOpen;
            }
        }

        public void setVideoStatus(string usrID, bool bVideoOpen)
        {
            MemInfo info = findMember(usrID);
            if (info != null)
            {
                info.bOpenVideo = bVideoOpen;
            }
        }

        public void setAudioEnergy(string usrID, int level)
        {
            MemInfo info = findMember(usrID);
            if (info != null)
            {
                if (info.bOpenAudio)
                    info.energyLevel = level;
                else
                    return;
            }
        }

        private void btn_audio_click(object sender, RoutedEventArgs e)
        {
            string usrID = ((Button)sender).Tag.ToString();
            MemInfo iter = findMember(usrID);
            if (iter == null)
            {
                return;
            }
            if (iter.bOpenAudio)
                App.CRVideo.VideoSDK.closeMic(usrID);
            else
                App.CRVideo.VideoSDK.openMic(usrID);
        }

        private void btn_video_click(object sender, RoutedEventArgs e)
        {
            string usrID = ((Button)sender).Tag.ToString();
            MemInfo iter = findMember(usrID);
            if (iter == null)
            {
                return;
            }

            if (iter.bOpenVideo)
                App.CRVideo.VideoSDK.closeVideo(usrID);
            else
                App.CRVideo.VideoSDK.openVideo(usrID);

        }


        private void item_change_name_clicked(object sender, RoutedEventArgs e)
        {
            string usrID = ((MenuItem)sender).Tag.ToString();
            InputWnd wnd = new InputWnd();
            wnd.setTitle("请输入新的昵称名:");
            bool? result = wnd.ShowDialog();
            if (result == true)
            {
                string nickName = wnd.getInputText();
                App.CRVideo.VideoSDK.setNickName(usrID, nickName);
            }  
        }

        public void setNickNameRsp(object sender, ICloudroomVideoSDKEvents_setNickNameRspEvent e)
        {
            if(e.p_err != 0)
            {
                MessageBox.Show("昵称设置失败:" + e.p_err.ToString());
            }
            else
            {
                MessageBox.Show("昵称设置成功");
            }
        }

        public void notifyNickNameChanged(object sender, ICloudroomVideoSDKEvents_notifyNickNameChangedEvent e)
        {
            MemInfo iter = findMember(e.p_userID);
            if (iter == null)
            {
                return;
            }

            iter.Name = e.p_newname;
        }

    }
}
