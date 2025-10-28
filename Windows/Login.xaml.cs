using System;
using System.Text;
using System.Windows;
using AxnpcloudroomvideosdkLib;
using System.Diagnostics;
using System.IO;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace SDKDemo
{
    /// <summary>
    /// Window1.xaml 的交互逻辑
    /// </summary>
    public partial class Login : Window
    {

        private static Login instance = null; //登陆界面使用单例模式
        private string mUserID = "";
        private int mMeetID = 0;

        public Login()
        {
            InitializeComponent();

            initDelegate();
            instance = this;    //单例对象赋值

            IniFile iniFile = new IniFile(Directory.GetCurrentDirectory() + "/meeting.ini");  //获取当前根目录
            edtNickname.Text = iniFile.ReadValue("Cfg", "LastUser", "");
        }

        //服务端消息处理使用异步消息弹框，防止阻塞对服务器的响应
        private delegate void messageBoxDelegate(string desc);
        private void BeginInvokeMessageBox(string desc) { MessageBox.Show(this, desc); }

        public static Login Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new Login();
                }
                return instance;
            }
        }

        public string myUserID
        {
            get { return mUserID; }
        }

        public int MeetID 
        { 
            get { return mMeetID; }
            set { mMeetID = value; }
        }

        private void initDelegate()
        {            
            App.CRVideo.VideoSDK.loginSuccess += loginSuccess;
            App.CRVideo.VideoSDK.loginFail += loginFailed;
        }

        private void btnLogin_Click(object sender, RoutedEventArgs e)
        {
            if (edtNickname.Text.Trim() == "")
            {
                MessageBox.Show("请输入昵称");
                return;
            }

            if (edtNickname.Text.Trim().Length > 15)
            {
                MessageBox.Show("昵称长度不能超过15");
                return;
            }

            IniFile iniFile = new IniFile(Directory.GetCurrentDirectory() + "/meeting.ini");

            //sdk参数
            JObject sdkParamJson = new JObject();
            string sdkParamsBase64Str = iniFile.ReadValue("Cfg", "SDKParams", "");
            var sdkParamsBase64by = Convert.FromBase64String(sdkParamsBase64Str);
            string strSDKParams = System.Text.Encoding.Default.GetString(sdkParamsBase64by);
            try
            {
                JObject josnTmp = (JObject)JsonConvert.DeserializeObject(strSDKParams);
                if (josnTmp != null)
                {
                    sdkParamJson = josnTmp;
                }
            }
            catch (Exception ex)
            {
            }


            int httpType = Convert.ToInt32(iniFile.ReadValue("Cfg", "HttpType", "2"));
            if ( httpType==0 )
            {
                sdkParamJson.Add("DatEncType", 0);
            }
            else
            {
                sdkParamJson.Add("DatEncType", 1);
                sdkParamJson.Add("VerifyHttpsCert", (httpType==2)? 1:0);
            }
            string sdkParamJsonStr = JsonConvert.SerializeObject(sdkParamJson);
            App.CRVideo.VideoSDK.setSDKParams(sdkParamJsonStr);

            //初始化sdk 
            App.CRVideo.VideoSDK.init_2(Environment.CurrentDirectory);

            //配置网络代理
            int type = Int32.Parse(iniFile.ReadValue("Cfg", "ProxyType", "0"));
            string addr = iniFile.ReadValue("Cfg", "ProxyAddr", "");
            string port = iniFile.ReadValue("Cfg", "ProxyPort", "");
            string name = iniFile.ReadValue("Cfg", "ProxyName", "");
            string pswd = iniFile.ReadValue("Cfg", "ProxyPswd", "");
            JObject json = new JObject();
            json.Add("type", type);
            json.Add("addr", addr);
            json.Add("port", port);
            json.Add("name", name);
            json.Add("pswd", pswd);
            string jsonData = JsonConvert.SerializeObject(json);
            App.CRVideo.VideoSDK.setNetworkProxy(jsonData);

            //配置服务器
            App.CRVideo.VideoSDK.serverAddr = iniFile.ReadValue("Cfg", "LastServer", AccountInfo.TEST_Server);

            mUserID = edtNickname.Text.Trim();      //账号ID，此处采用登陆昵称，实际开发中按照自己的业务需求取值，需保证其在此会话参与者中的唯一性

            int selectedType = Convert.ToInt32(iniFile.ReadValue("Cfg", "AuthType", "0"));
            if(selectedType == 0)
            {
                string account = iniFile.ReadValue("Cfg", "LastAccount", AccountInfo.TEST_AppID);
                string password = iniFile.ReadValue("Cfg", "LastPwd", App.getMD5Value(AccountInfo.TEST_AppSecret));
                App.CRVideo.VideoSDK.login(account, password, myUserID, "", ""); 
            }
            else
            {
                string token = iniFile.ReadValue("Cfg", "Token", "");
                App.CRVideo.VideoSDK.loginByToken(token, myUserID, "", "");
              
            }
            btnLogin.IsEnabled = false;
            iniFile.WriteValue("Cfg", "LastUser", myUserID); 
        }

        private void loginSuccess(object sender, ICloudroomVideoSDKEvents_loginSuccessEvent e)
        {
            Console.WriteLine("login succeed...");
            btnLogin.IsEnabled = true;

            StartMeetingWin win = new StartMeetingWin(this, edtNickname.Text);           
            win.Show();
            this.Visibility = Visibility.Hidden;
        }

        private void loginFailed(object sender, ICloudroomVideoSDKEvents_loginFailEvent e)
        {
            btnLogin.IsEnabled = true;
            Console.WriteLine("loginFailed:" + e.p_sdkErr);
            Dispatcher.BeginInvoke(new messageBoxDelegate(BeginInvokeMessageBox), new object[] { "登陆出错，请重试, " + CRError.Instance.getError(e.p_sdkErr) });

            logout();
        }

        public void logout()
        {
            this.ShowInTaskbar = true;
            this.Visibility = Visibility.Visible;
            App.CRVideo.VideoSDK.logout();
            App.CRVideo.VideoSDK.uninit();
        }

        private void Window_Closed(object sender, EventArgs e)
        {           
            try
            {
            }
            catch(System.Exception)
            {

             }
            finally
            {
              
            }
            
        }

        private void btnSet_Click(object sender, RoutedEventArgs e)
        {
            Set set = new Set(this);
            set.ShowDialog();
        }
    }
}
