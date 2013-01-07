using System;
using System.Linq;
using System.Collections.Generic;
using System.Windows.Forms;
using Connection;

namespace Shipping
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [MTAThread]
        static void Main()
        {
            FXRFGlobals.GetFXMESGlobals();

#if PocketPC
            SymbolRFGun.SymbolRFGun myRFGun = new SymbolRFGun.SymbolRFGun();
            FXRFGlobals.MyRFGun = myRFGun;
#endif

            Controller con;
            con = new Controller();

#if PocketPC
            FXRFGlobals.MyRFGun.StopRead();
            if (myRFGun != null) myRFGun.Close();
#endif
        }

    }
}