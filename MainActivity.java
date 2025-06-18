package com.example.iframeventbind;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

public class MainActivity extends AppCompatActivity {

    private Button mainWebsiteBtn, iframBtn, ifram2Btn;
    private SwipeRefreshLayout swipeRefreshLayout;
    private WebView webView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        mainWebsiteBtn = (Button) findViewById(R.id.mainWebsiteBtn);
        iframBtn = (Button) findViewById(R.id.iframBtn);
        ifram2Btn = (Button) findViewById(R.id.ifram2Btn);

        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.swipeRefreshLayout);

        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                swipeRefreshLayout.setRefreshing(true);
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        swipeRefreshLayout.setRefreshing(false);
                        webView.reload();
                    }
                }, 2000);
            }
        });

        webView = findViewById(R.id.webViewShow);

        webView.setWebViewClient(new WebViewClient());
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true); // For local content

        webView.addJavascriptInterface(new WebAppInterface(this), "Android");
        webView.addJavascriptInterface(new JSBridge(this, swipeRefreshLayout), "AndroidScroll");
        webView.loadUrl("http://192.168.2.175:5500/website.html");


        mainWebsiteBtn.setOnClickListener(v -> {
            webView.evaluateJavascript("javascript:fromAndroidToWebSite('Hello Website')", null);
        });

        iframBtn.setOnClickListener(v -> {
            webView.evaluateJavascript("javascript:fromAndroidToIFrame('Hello Iframe')", null);
        });

        ifram2Btn.setOnClickListener(v -> {
            webView.evaluateJavascript("javascript:fromAndroidToIFrame2('Hello Iframe 2')", null);
        });

        // Pull to refresh



        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }


    public class WebAppInterface {
        Context mContext;

        WebAppInterface(Context context) {
            mContext = context;
        }

        @JavascriptInterface
        public void onButtonClicked(String message) {
            Toast.makeText(mContext, "JS Button clicked: " + message, Toast.LENGTH_SHORT).show();
        }
    }

    public class JSBridge {
        SwipeRefreshLayout swipeRefreshLayout; // local variable
        Context mContext;
        public JSBridge(Context context, SwipeRefreshLayout swipeLayout) {
            this.swipeRefreshLayout = swipeLayout;  // global variable
            mContext = context;
        }

        @JavascriptInterface
        public void disableRefresh() {
           // Toast.makeText(mContext, "Disable Refresh: ", Toast.LENGTH_SHORT).show();
            this.swipeRefreshLayout.setEnabled(false);
            //swipeRefreshLayout.post(() -> swipeRefreshLayout.setEnabled(false));
        }

        @JavascriptInterface
        public void enableRefresh() {
           // Toast.makeText(mContext, "Enable Refresh: ", Toast.LENGTH_SHORT).show();
            this.swipeRefreshLayout.setEnabled(true);
           // swipeRefreshLayout.post(() -> swipeRefreshLayout.setEnabled(true));
        }
    }

}