﻿using System;
using System.Text;
using System.Windows;
using System.Security.Cryptography;

namespace SDKDemo
{
    /// <summary>
    /// App.xaml 的交互逻辑
    /// </summary>
    public partial class App : Application
    {
        App()
        {

        }

        public static CRVideoSDK CRVideo
        {
            get
            {
                return cr_sdk_video_instance;
            }
        }

        private static CRVideoSDK cr_sdk_video_instance = new CRVideoSDK();
        static public string getMD5Value(string text)
        {
            byte[] input = Encoding.Default.GetBytes(text);
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] output = md5.ComputeHash(input);
            return BitConverter.ToString(output).Replace("-", "").ToLower();
        }
    }

    public class IniFile
    {
        // 声明INI文件的写操作函数 WritePrivateProfileString()
        [System.Runtime.InteropServices.DllImport("kernel32")]
        private static extern long WritePrivateProfileString(string section, string key, string val, string filePath);

        // 声明INI文件的读操作函数 GetPrivateProfileString()
        [System.Runtime.InteropServices.DllImport("kernel32")]
        private static extern int GetPrivateProfileString(string section, string key, string def, System.Text.StringBuilder retVal, int size, string filePath);

        private string sPath = null;
        public IniFile(string path)
        {
            this.sPath = path;
        }

        public void WriteValue(string section, string key, string value)
        {
            // section=配置节，key=键名，value=键值，path=路径
            WritePrivateProfileString(section, key, value, sPath);
        }

        public string ReadValue(string section, string key, string defalueValue)
        {
            // 每次从ini中读取多少字节
            System.Text.StringBuilder temp = new System.Text.StringBuilder(255);
            // section=配置节，key=键名，temp=上面，path=路径
            GetPrivateProfileString(section, key, defalueValue, temp, 255, sPath);
            return temp.ToString();
        }
    }
}
