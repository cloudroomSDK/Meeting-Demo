using System.Windows.Forms;
using AxnpcloudroomvideosdkLib;

namespace SDKDemo
{
    public partial class CRVideoSDK : UserControl
    {
        public CRVideoSDK()
        {
            InitializeComponent();
        }

        public AxCloudroomVideoSDK VideoSDK
        {
            get { return axCRVideo; }
        }
    }
}
