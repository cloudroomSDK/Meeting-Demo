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
    /// InputWnd.xaml 的交互逻辑
    /// </summary>
    public partial class InputWnd : Window
    {
        public InputWnd()
        {
            InitializeComponent();
            
        }

        public void setTitle(string title)
        {
            this.Title = title;
        }
        public string getInputText()
        {
            return inputText.Text;
        }

        private void btn_ok_clicked(object sender, RoutedEventArgs e)
        {
            this.DialogResult = true;
            Close();
        }
    }
}
