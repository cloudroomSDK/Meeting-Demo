using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using AxnpcloudroomvideosdkLib;

namespace Meeting_WPF
{
    public partial class BoardUI : UserControl
    {
        public BoardUI()
        {
            InitializeComponent();

        }
        public AxCloudroomBoardUI axBoard
        {
            get { return axCloudroomBoardUI1; }
        }
 
    }
}
