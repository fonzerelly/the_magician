# The Magician

## TDD oder Testdriven development
- Zu jeder gewünschten Änderung wird als erstes ein Unittest geschrieben. Dieser sollte aus dem richtigen Grund fehlschlagen. Z.B. Wenn ich eine Methode aufrufe und erwarte den Rückgabewert "X", aber anstatt dass die Methode mir irgendwas liefert wird eine exception geworfen, weil die Methode ja noch nicht existiert. Das wäre z.B. ein "falscher" Grund dass so ein Test scheitert. Du musst den Test so lange korrigieren, bis nur noch das Fehl schlägt was im Assert gewünscht ist. Erst dann wird der Produktionscode von dir angepasst, so dass der Test Grün wird. Wenn der Test Gründ wird kann die nächste kleine Änderung vorgenommen werden.
  
## Protokoll
Schreib zu jeder Methode in eine doc.md-Datei was sie konkret tut, so dass ich leicht nachvollziehen kann was du programmiert hast. 

## Generelle Anweisung
Wenn du Tests ausführen willst, nutze run-tests.sh
Wenn du die App starten willst, nutze start-app.sh
wenn du die App bauen willst, nutze build.sh

Wenn Du feststellst, dass Du für Tests, builds oder so mehr freiraum brauchst, dann kannst und sollst du die shell-skripte um einen eingabeparameter erweitern und dann weiterhin das skript nutzen.

## Oberste Priorität sollte sein, dass du jedweden Code den du generierst möglichst menschen lesbar gestalltest.
Falls aber die Performance darunter massiv leidet, dann solltest Du einen Kommentar dazu schreiben, warum der Code an der stelle nun leider unlesbar bzw. schwer nachzuvollziehen sein muss. 

## pushen
git push sollte bitte nur auf meine explizite aufforderung passieren. Denn git push triggert ja eine github action die die app neu deployed. Und das heißt, es gibt immer auch ein Risiko, dass dabei was schief geht. Bzw. möglicherweise möchte ich ein Teilfeature schon mal committen, aber es ist noch nicht vollständig, so das es noch nicht released werden soll. Also git push bitte IMMER explizit abwarten.