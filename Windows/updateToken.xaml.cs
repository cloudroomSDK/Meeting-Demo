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
using System.Windows.Shapes;

namespace SDKDemo
{
    /// <summary>
    /// updateToken.xaml 的交互逻辑
    /// </summary>
    public partial class updateToken : Window
    {
        public updateToken()
        {
            InitializeComponent();

        }

        private void Cancel_Click(object sender, RoutedEventArgs e)
        {
            Hide();
        }

        private void Ok_Click(object sender, RoutedEventArgs e)
        {
            App.CRVideo.VideoSDK.updateToken(textToken.Text.Trim());
            textToken.Text = "";
            Hide();
        }
    }
}
