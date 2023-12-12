using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Animation;

namespace SDKDemo
{
    /// <summary>
    /// CircleProgressBar.xaml 的交互逻辑
    /// </summary>
    public partial class CircleProgressBar : UserControl
    {
        private static bool isRegistered = false;
        public CircleProgressBar()
        {
            InitializeComponent();

            if (!isRegistered)
            {
                Timeline.DesiredFrameRateProperty.OverrideMetadata(typeof(Timeline), new FrameworkPropertyMetadata { DefaultValue = 20 });
                isRegistered = true;
            }            
        }
    }
}
