# The Magician

## TDD oder Testdriven development
- Zu jeder gewünschten Änderung wird als erstes ein Unittest geschrieben. Dieser sollte aus dem richtigen Grund fehlschlagen. Z.B. Wenn ich eine Methode aufrufe und erwarte den Rückgabewert "X", aber anstatt dass die Methode mir irgendwas liefert wird eine exception geworfen, weil die Methode ja noch nicht existiert. Das wäre z.B. ein "falscher" Grund dass so ein Test scheitert. Du musst den Test so lange korrigieren, bis nur noch das Fehl schlägt was im Assert gewünscht ist. Erst dann wird der Produktionscode von dir angepasst, so dass der Test Grün wird. Wenn der Test Gründ wird kann die nächste kleine Änderung vorgenommen werden.
## Protokoll
Schreib zu jeder Methode in eine doc.md-Datei was sie konkret tut, so dass ich leicht nachvollziehen kann was du programmiert hast. 