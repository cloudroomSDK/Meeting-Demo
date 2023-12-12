using System;
using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace SDKDemo
{
    /// <summary>
    /// Set.xaml 的交互逻辑
    /// </summary>
    public partial class Set : Window
    {
        private bool mIsPasswrodChanged = false;
        public Set(Window parent)
        {
            InitializeComponent();

            this.Owner = parent;
            ShowInTaskbar = false;   

            IniFile iniFile = new IniFile(Directory.GetCurrentDirectory() + "/meeting.ini");  //获取当前根目录
            edtServer.Text = iniFile.ReadValue("Cfg", "LastServer", "sdk.cloudroom.com");
            cbHttpType.SelectedIndex = Convert.ToInt32(iniFile.ReadValue("Cfg", "HttpType", "2"));
            edtAccount.Text = iniFile.ReadValue("Cfg", "LastAccount", "");
            edtPassword.Password = iniFile.ReadValue("Cfg", "LastPwd", "");
            if( edtAccount.Text=="" )
            {
                setDefAcnt();
            }

            cbType.SelectionChanged += AuthTypeChanged;
            int selectedIndex = Convert.ToInt32(iniFile.ReadValue("Cfg", "AuthType", "0"));
            edtToken.Text = iniFile.ReadValue("Cfg", "Token", "");

            
            proxyAddr.Text = iniFile.ReadValue("Cfg", "ProxyAddr", "");
            proxyPort.Text = iniFile.ReadValue("Cfg", "ProxyPort", "");
            proxyUsr.Text = iniFile.ReadValue("Cfg", "ProxyName", "");
            proxyPwd.Text = iniFile.ReadValue("Cfg", "ProxyPswd", "");
           
            proxyType.SelectedIndex = Convert.ToInt32(iniFile.ReadValue("Cfg", "ProxyType", "0"));
            cbType.SelectedIndex = selectedIndex;

            string sdkParamsBase64Str = iniFile.ReadValue("Cfg", "SDKParams", "");
            var sdkParamsBase64by = Convert.FromBase64String(sdkParamsBase64Str);
            sdkParamEdt.Text = System.Text.Encoding.Default.GetString(sdkParamsBase64by);

            mIsPasswrodChanged = false;
        }

        void AuthTypeChanged(object sender, SelectionChangedEventArgs e)
        {
            if(cbType.SelectedIndex == 0)
            {
                labelAccount.Visibility = System.Windows.Visibility.Visible;
                edtAccount.Visibility = System.Windows.Visibility.Visible;
                labelToken.Visibility = System.Windows.Visibility.Hidden;
                edtToken.Visibility = System.Windows.Visibility.Hidden;
                labelPassword.Visibility = System.Windows.Visibility.Visible;
                edtPassword.Visibility = System.Windows.Visibility.Visible;
            }
            else
            {
                labelAccount.Visibility = System.Windows.Visibility.Hidden;
                edtAccount.Visibility = System.Windows.Visibility.Hidden;
                labelToken.Visibility = System.Windows.Visibility.Visible;
                edtToken.Visibility = System.Windows.Visibility.Visible;
                labelPassword.Visibility = System.Windows.Visibility.Hidden;
                edtPassword.Visibility = System.Windows.Visibility.Hidden;
            }
        }

        private void setDefAcnt()
        {
            if( AccountInfo.TEST_AppID=="" )
            {
                edtAccount.Text = "";
                edtPassword.Password = "";
            }
            else
            {
                edtAccount.Text = "默认APPID";
                edtPassword.Password = "*";
            }
        }

        //默认设置
        private void btnDefault_Clicked(object sender, RoutedEventArgs e)
        {
            proxyType.SelectedIndex = 0;
            edtServer.Text = "sdk.cloudroom.com";
            cbType.SelectedIndex = 0;
            sdkParamEdt.Text = "";
            setDefAcnt();

            save2File();
        }

        //关闭时保存设置
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
        }

        private void edtPassword_PasswordChanged(object sender, RoutedEventArgs e)
        {
            mIsPasswrodChanged = true;
        }

        private void btnSave_Click(object sender, RoutedEventArgs e)
        {
            if (edtServer.Text.Trim() == "" || edtAccount.Text.Trim() == "" || edtPassword.Password == "")
            {
                MessageBox.Show("请完成输入！");  
                return;
            }

            string sdkParams = sdkParamEdt.Text.Trim();
            if( sdkParams.Length>0 )
            {
                try
                {
                    object jsonObj = JsonConvert.DeserializeObject(sdkParams);
                }
                catch (Exception ex)
                {
                    MessageBox.Show("SDK Params参数不正确！");
                    return;
                }
            }

            save2File();
            Close();
        }

        private void save2File()
        {
            IniFile iniFile = new IniFile(Directory.GetCurrentDirectory() + "/meeting.ini");  //获取当前根目录
            iniFile.WriteValue("Cfg", "LastServer", edtServer.Text);
            iniFile.WriteValue("Cfg", "HttpType", cbHttpType.SelectedIndex.ToString());
            iniFile.WriteValue("Cfg", "Token", edtToken.Text);
            iniFile.WriteValue("Cfg", "AuthType", cbType.SelectedIndex.ToString());
            iniFile.WriteValue("Cfg", "ProxyType", proxyType.SelectedIndex.ToString());
            iniFile.WriteValue("Cfg", "ProxyAddr", proxyAddr.Text);
            iniFile.WriteValue("Cfg", "ProxyPort", proxyPort.Text.Trim());
            iniFile.WriteValue("Cfg", "ProxyName",  proxyUsr.Text.Trim());
            iniFile.WriteValue("Cfg", "ProxyPswd",  proxyPwd.Text.Trim());

            string strParams = Convert.ToBase64String(System.Text.Encoding.Default.GetBytes(sdkParamEdt.Text.Trim()));
            iniFile.WriteValue("Cfg", "SDKParams", strParams);
           
            if (edtAccount.Text != "默认APPID")
            {
                iniFile.WriteValue("Cfg", "LastAccount", edtAccount.Text);
                iniFile.WriteValue("Cfg", "LastPwd", mIsPasswrodChanged ? App.getMD5Value(edtPassword.Password) : edtPassword.Password);                
            }
            else
            {
                iniFile.WriteValue("Cfg", "LastAccount", null);
                iniFile.WriteValue("Cfg", "LastPwd", null);
            }
        }

        private void proxyTypeChanged(object sender, SelectionChangedEventArgs e)
        {
            if(proxyType.SelectedIndex == 0)
            {
                proxyAddr.Clear();
                proxyPort.Clear();
                proxyPwd.Clear();
                proxyUsr.Clear();
                proxyAddr.IsEnabled = false;
                proxyPort.IsEnabled = false;
                proxyUsr.IsEnabled = false;
                proxyPwd.IsEnabled = false;
            }
            else 
            {
                proxyAddr.IsEnabled = true;
                proxyPort.IsEnabled = true;
                proxyUsr.IsEnabled = true;
                proxyPwd.IsEnabled = true;
            }
        }
    }
}
