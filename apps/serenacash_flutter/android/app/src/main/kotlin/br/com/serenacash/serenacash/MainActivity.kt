package br.com.serenacash.mobile

import android.content.Intent
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity, não FlutterActivity: o prompt de biometria do Android (androidx.biometric,
// usado pelo plugin local_auth) só abre a partir de uma FragmentActivity. Com FlutterActivity toda
// tentativa de confirmar pelo aparelho falhava antes de mostrar o prompt.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "br.com.serenacash.mobile/window")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Com o bloqueio do app ativado, a janela fica fora de capturas de tela, gravações
                    // e da miniatura da lista de apps recentes (FLAG_SECURE).
                    "setSecure" -> {
                        val secure = call.arguments as? Boolean ?: false
                        runOnUiThread {
                            if (secure) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            }
                        }
                        result.success(null)
                    }
                    // Tela do Android onde se cadastra bloqueio de tela e biometria.
                    "openSecuritySettings" -> {
                        try {
                            startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS))
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
