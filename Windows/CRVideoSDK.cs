using System.Windows.Forms;
using AxnpcloudroomvideosdkLib;

namespace Meeting_WPF
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
