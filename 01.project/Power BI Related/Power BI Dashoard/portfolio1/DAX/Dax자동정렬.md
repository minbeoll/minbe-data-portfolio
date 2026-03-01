tabluar에 c script 창에



var measures = Model.AllMeasures;



var sb = new System.Text.StringBuilder();



foreach (var m in measures)

{

&nbsp;   sb.AppendLine(m.Name + " =");

&nbsp;   sb.AppendLine(m.Expression);

&nbsp;   sb.AppendLine();

}



// 결과를 클립보드로 복사

System.Windows.Forms.Clipboard.SetText(sb.ToString());



입력하면 자동정렬 클립보드 자동생성



