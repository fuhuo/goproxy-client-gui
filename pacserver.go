package main

import (
	"fmt"
	"net/http"
	"os"

	// "os/exec"
	// "path/filepath"
	"io/ioutil"
	"strings"
)

var host string
var listenPort string
var proxyPort string

// func PathExists(path string) (bool, error) {
// 	_, err := os.Stat(path)
// 	if err == nil {
// 		return true, nil
// 	}
// 	if os.IsNotExist(err) {
// 		return false, nil
// 	}
// 	return false, err
// }

// func GetCurrPath() string {
// 	file, _ := exec.LookPath(os.Args[0])
// 	path, _ := filepath.Abs(file)
// 	splitstring := strings.Split(path, "\\")
// 	size := len(splitstring)
// 	splitstring = strings.Split(path, splitstring[size-1])
// 	ret := strings.Replace(splitstring[0], "\\", "/", size-1)
// 	return ret
// }

// func FileExists(path string) (bool, error) {
// 	_, err := os.Stat(path)
// 	if err == nil {
// 		return true, nil
// 	}
// 	if os.IsNotExist(err) {
// 		return false, nil
// 	}
// 	return false, err
// }

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
	pactxt := strings.Replace(pactmpl, "__PROXY__", "PROXY "+host+":"+proxyPort+";", -1)
	fmt.Fprintf(w, pactxt)
}

func main() {
	// fmt.Println(GetCurrPath())
	if len(os.Args[1:]) > 0 {
		host = os.Args[1]
		listenPort = os.Args[2]
		proxyPort = os.Args[3]
	} else {
		host = "127.0.0.1"
		listenPort = "1079"
		proxyPort = "1080"
	}
	fmt.Println(listenPort)
	// path:="pac"
	// file:="pac.txt"
	// exist,e:=PathExists(path)
	// if(!exist){
	// 	e=os.Mkdir("file",0777)
	// }

	// exist,e=FileExists(path+"/"+file)
	// if(!exist){
	// 	f,_:=os.Create(path+"/"+file)
	// 	_,e=f.WriteString(fmt.Sprintf("hello world!!!"))
	// 	e=f.Close()
	// }

	// filepath := path + "/" + file
	// http.Handle("/pac/", http.StripPrefix("/pac/", http.FileServer(http.Dir(path))))
	http.HandleFunc("/pacfile", pacHandler)
	e := http.ListenAndServe(host+":"+listenPort, nil)
	if e != nil {
		fmt.Println(e.Error())
	}
}
