## Task 1: Formulieren Sie folgende Anfragen auf dem bekannten Universitätsschema in SQL. Geben Sie alle Ergebnisse duplikatfrei aus.

# 1. Finden Sie die Studenten, die Sokrates aus Vorlesung(en) kennen.
select distinct s.Name, s.MatrNr
from Studenten s, hoeren h, Vorlesungen v, Professoren p
where s.Matrnr=h.Matrnr and h.VorlNr=v.VorlNr 
and v.gelesenVon=p.PersNr and p.Name='Sokrates' 

# 2. blalallala