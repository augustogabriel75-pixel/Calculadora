// VetClin Preço de Venda para Windows: abre a calculadora (index.html embutido)
// numa janela própria usando o WebView2 do Windows 10/11. Os dados ficam em
// %APPDATA%\VetClin Preco de Venda\dados.json.
package main

import (
	_ "embed"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
	"unsafe"

	webview2 "github.com/jchv/go-webview2"
)

//go:embed app/index.html
var page string

func dataDir() string {
	base := os.Getenv("APPDATA")
	if base == "" {
		base, _ = os.UserConfigDir()
	}
	d := filepath.Join(base, "VetClin Preco de Venda")
	os.MkdirAll(d, 0o755)
	return d
}

func writeAtomic(path, s string) error {
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, []byte(s), 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

func messageBox(title, text string) {
	t, _ := syscall.UTF16PtrFromString(title)
	m, _ := syscall.UTF16PtrFromString(text)
	syscall.NewLazyDLL("user32.dll").NewProc("MessageBoxW").Call(0, uintptr(unsafe.Pointer(m)), uintptr(unsafe.Pointer(t)), 0x40)
}

func main() {
	dir := dataDir()
	dados := filepath.Join(dir, "dados.json")

	w := webview2.NewWithOptions(webview2.WebViewOptions{
		AutoFocus: true,
		DataPath:  filepath.Join(dir, "webview"),
		WindowOptions: webview2.WindowOptions{
			Title: "VetClin · Preço de Venda", Width: 1280, Height: 860, IconId: 1, Center: true,
		},
	})
	if w == nil {
		// Sem WebView2: abre no navegador padrão (os dados ficam no navegador).
		html := strings.Replace(page, "window.VC_PLATFORM='windows'", "window.VC_PLATFORM='web'", 1)
		f := filepath.Join(dir, "VetClin-Preco-de-Venda.html")
		os.WriteFile(f, []byte(html), 0o644)
		messageBox("VetClin Preço de Venda", "O componente Microsoft Edge WebView2 não foi encontrado.\nA calculadora vai abrir no seu navegador.\n\nPara usar em janela própria, instale o \"WebView2 Runtime\" no site da Microsoft.")
		exec.Command("rundll32", "url.dll,FileProtocolHandler", f).Start()
		return
	}
	defer w.Destroy()

	w.Bind("vcLoad", func() (string, error) {
		b, err := os.ReadFile(dados)
		if os.IsNotExist(err) {
			return "", nil
		}
		return string(b), err
	})
	w.Bind("vcSave", func(s string) error {
		if old, err := os.ReadFile(dados); err == nil && len(old) > 0 {
			os.WriteFile(dados+".anterior", old, 0o644)
		}
		return writeAtomic(dados, s)
	})
	w.Bind("vcExport", func(s string) (string, error) {
		home, _ := os.UserHomeDir()
		docs := filepath.Join(home, "Documents")
		if _, err := os.Stat(docs); err != nil {
			docs = home
		}
		f := filepath.Join(docs, "VetClin-backup-"+time.Now().Format("2006-01-02-1504")+".json")
		return f, os.WriteFile(f, []byte(s), 0o644)
	})
	w.SetSize(1000, 640, webview2.HintMin)
	w.SetHtml(page)
	w.Run()
}
