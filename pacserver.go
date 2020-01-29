package main
 
import (
	"fmt"
	"net/http"
	"os"
	"strings"
	"io/ioutil"
)
 
var listenPort string
var proxyPort string
 
func ReadFile(path string) string {
	bytes, err := ioutil.ReadFile(path)
	if err != nil {
		fmt.Println("error: %s", err)
		return "err"
	}
	return string(bytes)
}

// 获取pac的模板并替换成当前的代理端口
func pacHandler(w http.ResponseWriter, r *http.Request) {
	pacfilepath := "pac.txt"
	pactmpl := ReadFile(pacfilepath)
	pactxt := strings.Replace(pactmpl, "__PROXY__", "PROXY 127.0.0.1:"+proxyPort+";", -1)
	fmt.Fprintf(w, pactxt)
}


func main()  {
	// fmt.Println(GetCurrPath())
	if(len(os.Args[1:])>0){
		listenPort = os.Args[1]
		proxyPort = os.Args[2]
	}else{
		listenPort = "1079" 
		proxyPort = "1080"
	}
	fmt.Println(listenPort)
	http.HandleFunc("/pacfile", pacHandler)
	e := http.ListenAndServe("127.0.0.1:" + listenPort, nil)
	if e!=nil{
		fmt.Println(e.Error())
	}
}