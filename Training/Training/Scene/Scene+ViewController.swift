/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

extension Scene {
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "MainSB", bundle: nil)
        switch self {
        case .login(let viewModel):
            let storyboard = UIStoryboard.init(name: "LoginSB", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            vc.viewModel = viewModel
            return vc
        case .mainVC(let viewModel):
            let vc = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            vc.viewModel = viewModel
            return vc
        case .detailVC(let viewModel):
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
            vc.viewModel = viewModel
            return vc
        case .detailModal(let merchant):
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailModal") as! DetailModal
            vc.merchant = merchant
            return vc
        }
    }
}

extension UIViewController{
   
    func toTransparentModal(){
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }

}


