using AxnpcloudroomvideosdkLib;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Forms;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace SDKDemo
{
    /// <summary>
    /// MediaSharePage.xaml 的交互逻辑
    /// </summary>
    public partial class MediaSharePage : System.Windows.Controls.UserControl
    {
        private MediaUI mMedia = null;
        public MediaSharePage()
        {
            InitializeComponent();
        }

        public void updateCtrl(bool bShow)
        {
            if(bShow)
                mMedia.Show();
            else
                mMedia.Hide();         
        }
        public void disableTool(string userID)
        {
            if (Login.Instance.myUserID != userID)
            {
                mMedia.disableToolBar(true);
               
            }
            else
            {
                mMedia.disableToolBar(false);
            }
        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            if (mMedia == null)
            {
                mMedia = new MediaUI();
            }
            mediaShareHost.Child = mMedia;
            mMedia.disableToolBar(true);
        }

      
    }
}
