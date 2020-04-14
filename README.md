# 前言
---
由于项目需求，对基于APNs的语音播报做一个预研探究。如场景：收到转账消息，实时收到推送并播放语音。

# 方案
----
基于通知扩展（Notification Service）来处理推送，可以保证 `App被杀死` 或者 `App在前后台时` 都能够处理推送并实时播报。

也可以通过发送`静默通知`，来实时播报。收到静默通知时，App会被系统拉活然后然后执行`application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) `,可以在内部播放音频播报。但是由于苹果官方文档有说明，静默通知是有限制的：（所以该方式我们放弃了）
- APNs若检测到较高频率的静默通知发送请求，可能会终止其发送
- 静默通知唤醒后台App，最多有30秒的时间处理系统回调
- 静默推送的优先级低，系统不能保证推送必达，大量的静默推送通知可能被系统将限制。苹果官方建议一个小时不超过2-3条静默推送
- [静默通知官方文档](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app?language=objc)

准备工作：
- 需要在Bundle中内置音频文件，如（0-9，元，点）等基础音频。
- 设置AppGroup

当接收通知时：
- 读取aps中的播报数据，读取Bundle中音频文件进行合并音频（如"您收到.mp3"+"1.mp3"+"元.mp3"），输出到指定目录。
- 修改本次推送声音标识`sound`，指定合并后的音频文件播报。最后达到语音播报目的。


注意点：
- 需设置AppGroup，通过共享目录创建音频目录和文件。
- 若有指定sound:"abc.mp3"，系统会逐级查找是否有可用的abc.mp3文件：
1. 查找AppGroup共享目录
2. 查找App NSHomeDirectory()+"/Library/Sounds/"
3. 查找bundle中是否有可用的abc.mp3
4. 查找系统音频库




GitHub Demo
---
[GitHub Demo ApnsDemo](https://github.com/aklee/ApnsDemo)
资源文件如有侵权 请联系删除。


# Test Payload
建议使用[SmartPush](https://github.com/shaojiankui/SmartPush)来测试推送

```
{
    "aps": {
        "alert": {
            "title": "title",
            "body": "body"
        },
    "transfer":"123",
     "mutable-content":1
    }
}
```

# 历史方案总结
以下方案均为调研过程中无法成功的方案一览；
- 方案一： App收到推送，通过sound指定播放固定音频（“收到一笔转账”）。前提：mp3\caf\m4a音频文件需要内置在bundle中，推送下发时指定文件名称。缺点：无法根据具体金额播报。

- 方案二： App在前台收到推送时，通过AVAudioSession 或者 AVSpeechSynthesisVoice播报。缺点：1 App在前台播报时，可以通过音量键调整音量。正常的推送抵达时，音量键或者关机键会即刻`中断播放`推送声音，所以本方案不是真正的推送音。2 App杀死情况下无法播报。

- 方案三： 通过通知扩展（Notification Service）播放音频。App通知扩展收到推送时，调用`AVAudioSession` 或者 `AVSpeechSynthesisVoice` 播报。可能在通知扩展刚推出的时是允许这种做法的。但现在苹果已经`不支持`在通知扩展中播放音频，即使调用相关函数也不会生效。

- 方案四： 通过通知扩展（Notification Service）发送本地通知播报。App通知扩展收到推送时，顺序创建多个本地通知，每个通知都播放内置音频，从而组成一句完整的播报音频。缺点：1 苹果已`不支持在通知扩展发送本地通知`。2 播放推送音频时，音量键或者关机键 会中断当前本地通知的音频播放。



 