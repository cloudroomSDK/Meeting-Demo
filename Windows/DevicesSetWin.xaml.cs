﻿using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Documents;
using Newtonsoft.Json;
using System.Windows.Controls;
using Newtonsoft.Json.Linq;
using System.Text.RegularExpressions;

namespace SDKDemo
{
    /// <summary>
    /// VideoSetWin.xaml 的交互逻辑
    /// </summary>

    public class CCamInfo
    {
        public int ID;
        public string NAME;
        public CCamInfo(int id, string name)
        {
            this.ID = id;
            this.NAME = name;
        }
        public override string ToString()
        {
            return this.NAME;
        }
    }

    public class CAudioInfo
    {
        public string ID;
        public string NAME;
        public CAudioInfo(string id, string name)
        {
            this.ID = id;
            this.NAME = name;
        }
        public override string ToString()
        {
            return this.NAME;
        }
    } 

    public partial class DevicesSetWin : Window
    {
        private MeetingMainWin.VideoWallLayoutChangeEvent mLayoutChangeEvt = null;  //视频布局变化事件对象
        private bool bInit = false;
        private bool mbExit = false;
        public DevicesSetWin(MeetingMainWin.VideoWallLayoutChangeEvent evt)
        {
            bInit = true;
            InitializeComponent();

            mLayoutChangeEvt = evt;
            this.FpsCmBox.SelectionChanged += new System.Windows.Controls.SelectionChangedEventHandler(this.ComboBox_SelectionChanged);
        }

        public void initDevs()
        {
            cmbCameras.IsEnabled = false;
            cmbMics.IsEnabled = false;
            cmbSpeakers.IsEnabled = false;

            //获取麦克风和扬声器设备
            AudioCfg aCfg = JsonConvert.DeserializeObject<AudioCfg>(App.CRVideo.VideoSDK.getAudioCfg());
            List<AudioInfo> micDevs = JsonConvert.DeserializeObject<List<AudioInfo>>(App.CRVideo.VideoSDK.getAudioMics());
            List<AudioInfo> spkDevs = JsonConvert.DeserializeObject<List<AudioInfo>>(App.CRVideo.VideoSDK.getAudioSpks());

            cmbMics.Items.Clear();
            CAudioInfo aDevInfo = new CAudioInfo("", "默认设备");
            cmbMics.Items.Add(aDevInfo);
            cmbMics.SelectedIndex = 0;
            //下拉列表加载设备
            for (int i = 0; i < micDevs.Count; i++)
            {
                AudioInfo dev = micDevs[i];
                aDevInfo = new CAudioInfo(dev.id, dev.name);
                cmbMics.Items.Add(aDevInfo);
                if ( aCfg.micID==aDevInfo.ID )
                {
                    cmbMics.Text = aDevInfo.NAME;
                }
            }

            cmbSpeakers.Items.Clear();
            aDevInfo = new CAudioInfo("", "默认设备");
            cmbSpeakers.Items.Add(aDevInfo);
            cmbSpeakers.SelectedIndex = 0;
            for (int i = 0; i < spkDevs.Count; i++)
            {
                AudioInfo dev = spkDevs[i];
                aDevInfo = new CAudioInfo(dev.id, dev.name);
                cmbSpeakers.Items.Add(aDevInfo);
                if (aCfg.spkID == aDevInfo.ID)
                {
                    cmbSpeakers.Text = aDevInfo.NAME;
                }
            }

            //获取视频设备
            cmbCameras.Items.Clear();
            int cameraId = App.CRVideo.VideoSDK.getDefaultVideo(Login.Instance.myUserID);
            List<VideoInfo> devs = JsonConvert.DeserializeObject<List<VideoInfo>>(App.CRVideo.VideoSDK.getAllVideoInfo(Login.Instance.myUserID));
            for (int i = 0; i < devs.Count; i++)
            {
                VideoInfo dev = devs[i];
                CCamInfo camInfo = new CCamInfo(dev.videoID, dev.videoName);
                cmbCameras.Items.Add(camInfo);
                if (cameraId == dev.videoID)
                {
                    cmbCameras.Text = dev.videoName;
                }
            }

            if (cameraId == 0 && devs.Count > 0) //如果还没选择设备，则选择一个
            {
                cmbCameras.SelectedIndex = 0;
                cameraId = devs[0].videoID;
                App.CRVideo.VideoSDK.setDefaultVideo(Login.Instance.myUserID, cameraId);
                Console.WriteLine("set camera:" + App.CRVideo.VideoSDK.getDefaultVideo(Login.Instance.myUserID));
            }
  
            cmbCameras.IsEnabled = true;
            cmbMics.IsEnabled = true;
            cmbSpeakers.IsEnabled = true;
        }

        public void initSetting()
        {
            Agc.IsChecked = true;
            Ans.IsChecked = true;
            Aec.IsChecked = true;

            //初始化音频设备
            AudioCfg cfg = new AudioCfg();
            cfg.micID = "";           //""为使用系统默认设备
            cfg.spkID = "";       //同上
            cfg.agc = Convert.ToInt16(Agc.IsChecked.Value);
            cfg.ans = Convert.ToInt16(Ans.IsChecked.Value);
            cfg.aec = Convert.ToInt16(Aec.IsChecked.Value);
            App.CRVideo.VideoSDK.setAudioCfg(JsonConvert.SerializeObject(cfg));

            App.CRVideo.VideoSDK.micVolume = (int)micBar.Value;
            App.CRVideo.VideoSDK.speakerVolume = (int)micBar.Value;

            rbVideoSpeed.IsChecked = true; //视频默认使用流畅优先
            cmbVideoSize.SelectedIndex = (int)(VIDEO_SHOW_SIZE.VSIZE_SZ_360-1);
            VDenoise.IsChecked = true;

            //是否开启多摄像头判断
            ckExtCameras.IsChecked = App.CRVideo.VideoSDK.getEnableMutiVideo(Login.Instance.myUserID) > 0;

            bInit = false;
            updateAudioCfg();
            updateVideoCfg();
        }

        public void uninit()
        {
            mbExit = true;
            this.Close();
        }
        //切换视频设备
        private void cmbCameras_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cmbCameras.IsEnabled == false)
                return;

            CCamInfo camInfo = (CCamInfo)cmbCameras.SelectedItem;
            App.CRVideo.VideoSDK.setDefaultVideo(Login.Instance.myUserID, camInfo.ID);
            Console.WriteLine("cmbCameras_SelectedIndexChanged, set camera:" + App.CRVideo.VideoSDK.getDefaultVideo(Login.Instance.myUserID));
        }
        //切换麦克风设备
        private void cmbMics_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cmbMics.IsEnabled == false)
                return;

            updateAudioCfg();
        }
        //切换扬声器设备
        private void cmbSpeakers_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (cmbSpeakers.IsEnabled == false)
                return;

            updateAudioCfg();
        }

        //是否启用多摄像头
        private void ckExtCameras_Click(object sender, RoutedEventArgs e)
        {
            Console.WriteLine("muti video state: " + (ckExtCameras.IsChecked == true));
            App.CRVideo.VideoSDK.setEnableMutiVideo(Login.Instance.myUserID, (ckExtCameras.IsChecked == true) ? 1 : 0);
        }

        private void cmbVideoSize_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            updateVideoCfg();
        }

        private void updateVDenoise(object sender, RoutedEventArgs e)
        {
            updateVDenoise();
        }
 
        private void updateVDenoise()
        {
            App.CRVideo.VideoSDK.setVideoDenoise(VDenoise.IsChecked==true);
        }

        private void micBar_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            App.CRVideo.VideoSDK.micVolume = (int)micBar.Value;
        }

        private void speakerBar_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            App.CRVideo.VideoSDK.speakerVolume = (int)speakerBar.Value;
        }

        private void rbVideoQuality_Checked(object sender, RoutedEventArgs e)
        {
            rbVideoSpeed.IsChecked = !rbVideoQuality.IsChecked;
            if (rbVideoQuality.IsChecked == true)
            {
                updateVideoCfg();
            }
        }

        private void rbVideoSpeed_Checked(object sender, RoutedEventArgs e)
        {
            rbVideoQuality.IsChecked = !rbVideoSpeed.IsChecked;
            if (rbVideoSpeed.IsChecked == true)
            {
                updateVideoCfg();
            }
        }

        public void updateVideoCfg()
        {
            if (bInit)
            {
                return;
            }

            VideoCfg cfg = new VideoCfg();
            cfg.size = cmbVideoSize.Text;
            if (FpsCmBox.SelectedIndex >= 0)
            {
                cfg.fps = Convert.ToInt32((string)FpsCmBox.SelectedItem);
            }
            else
            {
                cfg.fps = 15;
            }
            if (rbVideoQuality.IsChecked == true) //最佳质量(18~51, 越小质量越好)(未配置则使用内部默认值)
            {
                cfg.qp_min = 22;
                cfg.qp_max = 22;
            }
            else
            {
                cfg.qp_min = 22;
                cfg.qp_max = 40;
            }
            App.CRVideo.VideoSDK.setVideoCfg(JsonConvert.SerializeObject(cfg));
        }

        private void Windows_closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if(!mbExit)
            {
                this.Hide();
                e.Cancel = true;
            }
            
        }

        private void RadioButton_Checked(object sender, RoutedEventArgs e)
        {
            if (mLayoutChangeEvt == null)
                return;
            mLayoutChangeEvt.videoRation = 16F/9F; //16：9
            mLayoutChangeEvt.OnVideoRationChanged();
            updateVideoCfg();
        }

        private void RadioButton_Checked_1(object sender, RoutedEventArgs e)
        {
            if (mLayoutChangeEvt == null)
                return;

            mLayoutChangeEvt.videoRation = 4F/3F; //4：3
            mLayoutChangeEvt.OnVideoRationChanged();
            updateVideoCfg();
        }

        private void RadioButton_Checked_2(object sender, RoutedEventArgs e)
        {
            if (mLayoutChangeEvt == null)
                return;

            mLayoutChangeEvt.videoRation = 1F; //1：1
            mLayoutChangeEvt.OnVideoRationChanged();
            updateVideoCfg();
        }

        private void updateAudioCfg(object sender, RoutedEventArgs e)
        {
            updateAudioCfg();
        }
        private void updateAudioCfg()
        {
            if (bInit)
            {
                return;
            }

            AudioCfg cfg = new AudioCfg();
            if (cmbMics.SelectedIndex > 0)
            {
                CAudioInfo v = (CAudioInfo)cmbMics.SelectedItem;
                cfg.micID = v.ID;
            }
            if (cmbSpeakers.SelectedIndex > 0)
            {
                CAudioInfo v = (CAudioInfo)cmbSpeakers.SelectedItem;
                cfg.spkID = v.ID;
            }
            cfg.agc = Convert.ToInt16(Agc.IsChecked.Value);
            cfg.ans = Convert.ToInt16(Ans.IsChecked.Value);
            cfg.aec = Convert.ToInt16(Aec.IsChecked.Value);
            App.CRVideo.VideoSDK.setAudioCfg(JsonConvert.SerializeObject(cfg));

            micBar.Visibility = (cfg.agc>0)? Visibility.Hidden:Visibility.Visible;
        }

        private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            updateVideoCfg();
        }


    }
}
