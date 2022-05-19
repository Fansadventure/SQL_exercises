#### Hausaufgabe 1
Formulieren Sie folgende Anfragen auf dem bekannten Universitätsschema in SQL. Geben Sie alle Ergebnisse duplikatfrei aus.

1.1 Finden Sie die Studenten, die Sokrates aus Vorlesung(en) kennen.
```sql
select distinct s.name, s.matrnr 
from studenten s, hoeren h, vorlesungen v, professoren p
where s.matrnr = h.matrnr 
    and h.vorlnr = v.vorlnr 
    and v.gelesenVon = p.persnr 
    and p.name='Sokrates';
```
1.2 Finden Sie die Studenten, die Vorlesungen hören, die auch Fichte hört.
```sql
select distinct s1.name, s1.matrnr
from studenten s1, hoeren h1, studenten s2, hoeren h2
where s1.matrnr = h1.matrnr 
	and s1.name != 'Fichte'
	and h1.vorlnr = h2.vorlnr
	and h2.matrnr = s2.matrnr
	and s2.name = 'Fichte';
-- The above solution is not working when a student takes more than one lecture. Better alternative_1:
with FichteVorl as (
select h.Matrnr, h.Vorlnr
from hoeren h, studenten s
where h.matrnr = s.matrnr 
    and s.name = 'Fichte'
)
select distinct s2.name, s2.matrnr
from studenten s2, hoeren h2, FichteVorl f
where s2.matrnr = h2.matrnr 
    and h2.vorlnr = f.vorlnr 
    and s2.name != 'Fichte';
-- alternative_2:
select * from studenten s1
where s1.name != 'Fichte' and not exists(
    select * from hoeren h1, studenten s2
    where h1.matrnr = s2.matrnr and s2.name='Fich'
    and h1.vorlnr not in (
        select h2.vorlnr 
        from hoeren h2, studenten s3
        where s3.matrnr = s1.matrnr 
        and h2.matrnr = s3.matrnr)
);
```
1.3 Finden Sie die Assistenten von Professoren, die den Studenten Carnap unterrichtet haben – z.B. als potentielle Betreuer seiner Bachelorarbeit.
```sql
select distinct a.name, a.persnr
from assistenten a, vorlesungen v, hoeren h, studenten s
where a.boss = v.gelesenVon 
    and v.vorlnr = h.vorlnr
	and h.matrnr = s.matrnr
	and s.name = 'Carnap';
```
1.4 Geben Sie die Namen der Professoren an, die Theophrastos aus Vorlesungen kennt.
```sql
select distinct p.* 
from professoren p, vorlesungen v, hoeren h, studenten s
where p.persnr = v.gelesenvon 
    and v.vorlnr = h.vorlnr 
    and h.matrnr = s.matrnr 
    and s.name = 'Theophrastos';
```
1.5 Welche *Vorlesungen* werden von *Studenten* im Bachelorstudium (1. – 6. Semester) gehört? Geben Sie die Titel dieser *Vorlesungen* an.
```sql
select distinct v.titel 
from vorlesungen v, hoeren h, studenten s
where v.vorlnr = h.vorlnr 
    and h.matrnr = s.matrnr 
	and s.semester between 1 and 6;  -- oder s.Semester <=6
```
1.6 Bestimmen Sie für jede Vorlesung wie viele Studenten diese hören. Geben Sie auch Vorlesungen ohne Hörer aus. Sortieren Sie das Ergebnis absteigend nach Anzahl der Hörer.
```sql
select v.VorlNr, v.Titel, count(h.MatrNr) as student
from Vorlesungen v 
left outer join hoeren h 
on v.VorlNr=h.VorlNr
group by v.VorlNr, v.Titel
order by student desc;  -- aufsteigend: asc
```
#### Hausaufgabe 2
Formulieren Sie die folgenden Anfragen auf dem bekannten Universitätsschema in SQL:

2.1 Bestimmen Sie das durchschnittliche Semester der Studenten der Universität.
```sql
select avg(semester*1.0) 
from studenten;
```
2.2 Bestimmen Sie das durchschnittliche Semester der Studenten, die mindestens eine Vorlesung bei Sokrates hören.
```sql
with studentSes as ( 
select distinct s.* 
from studenten s, hoeren h, vorlesungen v, professoren p
where s.matrnr = h.matrnr 
    and h.vorlnr = v.vorlnr 
	and v.gelesenvon = p.persnr 
    and p.name = 'Sokrates'
)
select avg(semester) from studentSes;
```
2.3 Bestimmen Sie, wie viele Vorlesungen im Schnitt pro Student gehört werden. Beachten Sie, dass Studenten, die keine Vorlesung hören, in das Ergebnis einfließen müssen.
```sql
select hcount/(scount*1.000)
from (select count(*) as hcount from hoeren) h,
        (select count(*) as scount from Studenten) s;
```

#### Hausaufgabe 3
Formulieren Sie die folgenden Anfragen auf dem bekannten Universitätsschema in SQL:

3.1 Finden Sie alle Studenten, die drei oder mehr Vorlesungen hören.
```sql
select s.matrnr, s.name 
from studenten s, hoeren h
where s.matrnr = h.matrnr
group by s.matrnr, s.name
having count(*) >= 3;

--alternative:
with vorlcount as (
  select matrnr, count(*) as vcount 
  from hoeren
  group by matrnr
  )
select s.matrnr, s.name 
from studenten s, vorlcount v
where s.matrnr = v.matrnr and v.vcount >= 3;
```
3.2 Finden Sie alle Grundlagenvorlesungen. Eine Vorlesung ist eine Grundlagenvorlesung, wenn sie mindestens 4 SWS hat und Voraussetzung von mindestens zwei anderen Vorlesungen ist.
```sql
select v.vorlnr, v.titel 
from vorlesungen v, voraussetzen vs
where v.vorlnr = vs.vorgaenger and v.sws >= 4
group by v.vorlnr, v.titel
having count(*) >= 2;
```
3.3 Bestimmen Sie das durchschnittliche Semester der Studenten, die mindestens eine Vorlesung bei Sokrates hören.
```sql
select avg(s.semester) from studenten s
where s.matrnr in ( 
-- 下面表示sokrates教的课的学生的集合, s.matrnr是该集合的元素
select h.matrnr 
    from professoren p, vorlesungen v, hoeren h
    where p.name = 'Sokrates' 
    and p.persnr = v.gelesenvon 
	and v.vorlnr = h.vorlnr
);

-- alternative
with SokratesStud as (
select distinct s.* 
from studenten s, hoeren h, vorlesungen v, professoren p
where s.matrnr = h.matrnr 
    and h.vorlnr = v.vorlnr 
    and v.gelesenvon = p.persnr 
    and p.name='Sokrates'
)
select avg(semester) from SokratesStud;

--aternative
select avg(semester) from
(select distinct s.* 
 from studenten s, hoeren h, vorlesungen v, professoren p
 where s.matrnr = h.matrnr 
 and h.vorlnr=v.vorlnr
 and v.gelesenvon = p.persnr 
 and p.name = 'Sokrates') 
--后面这select相当于with创建的临时的一个表
```
3.4 Bestimmen Sie, wie viele Vorlesungen im Schnitt pro Student gehört werden. Beachten Sie, das Studenten, die keine Vorlesung hören, in das Ergebnis einflieBen müssen.
```sql
select hcount*1.000/scount
from (select count(*) as hcount from hoeren) h, 
		 (select count(*) as scount from studenten) s
-- alternative:
select count(h.vorlnr)*1.000 / count(distinct s.matrnr)
from studenten s 
left outer join hoeren h 
on s.matrnr = h.matrnr;
```
#### Hausaufgabe 4
Gegeben sei ein erweitertes Universitätsschema mit den folgenden zusätzlichen Relationen *StudentenGF* und *ProfessorenF*:

StudentenGF  :  {[MatrNr : integer, Name : varchar(20), Semester : integer, Geschlecht : char, Fakultaet : varchar(20)]}
ProfessorenF  :  {[PersNr : integer, Name : varchar(20), Rang : char(2), Raum : integer, Fakultaet : varchar(20)]}

Die erweiterten Tabellen sind auch in der Webschnittstelle angelegt.

4.1 Ermitteln Sie den Männeranteil an den verschiedenen Fakultäten in SQL!
```sql
with fakuMan as (
  select fakultaet, count(*) as man 
  from studentenGF 
  where geschlecht='M' 
  group by fakultaet
  ),
fakuTotal as (
  select fakultaet, count(*) as total 
  from studentenGF 
  group by fakultaet
  )
 select ft.fakultaet, 
 (case when man is null then 0 else man end)/(ft.total*1.00)
 from fakutotal ft 
 left outer join fakuman fm 
 on ft.fakultaet = fm.fakultaet;

--Aternative:
select m1.fakultaet, 
case when man is null then 0 else man end /(m1.total*1.00)
from  (select fakultaet, count(*) as total 
       from  studentenGF group by fakultaet) m1 
       left outer join 
       (select fakultaet, count(*) as man
       from studentenGF 
       where geschlecht = 'M'
       group by fakultaet
       ) m2
      on m1.fakultaet=m2.fakultaet;
```

4.2 Finden Sie das „einfachste“ Nebenfach. Das „einfachste“ Nebenfach ist die Fakultät, deren Fremdprüfungen die beste Durchschnittsnote haben. Eine Prüfung ist eine Fremdprüfung, wenn sie von einem Prüfling von einer anderen Fakultät als der des/der Prüfers/Prüferin abgelegt wurde. Fakultäten ohne Fremdprüfungen müssen nicht beachtet werden.
```sql
with
Fakultaeten(name) as (
    select s.Fakultaet as name from StudentenGF s union
    select p.Fakultaet as name from ProfessorenF p
),
fremdprüfungenSchnitt(Fakultaet, Schnitt) as (
    select profs.Fakultaet, avg(p.Note)
    from pruefen p, StudentenGF s, ProfessorenF profs 
    where p.Matrnr = s.Matrnr
    and profs.PersNr = p.persnr
    and profs.Fakultaet <> s.Fakultaet
    group by profs.Fakultaet )
    
select f.name, fn.Schnitt
from fremdprüfungenSchnitt fn, Fakultaeten f
where fn.Fakultaet = f.name
and Schnitt = (select min(Schnitt) from fremdprüfungenSchnitt);
```

#### Hausaufgabe 5
Schreiben Sie eine SQL-Anfrage, die das kleine [Einmaleins](https://de.wikipedia.org/wiki/Einmaleins) in Tabellenform ausgibt. Tipp: Verwenden Sie WITH ... (VALUES ...)
```sql
with einmaleins as (values
(1, 2, 3, 4, 5, 6, 7, 8, 9,10),
(2, 4, 6, 8,10,12,14,16,18,20),
(3, 6, 9,12,15,18,21,24,27,30),
(4, 8,12,16,20,24,28,32,36,40),
(5,10,15,20,25,30,35,40,45,50),
(6,12,18,24,30,36,42,48,54,60),
(7,14,21,28,35,42,49,56,63,70),
(8,16,24,32,40,48,56,64,72,80),
(9,18,27,36,45,54,63,72,81,90),
(10,20,30,40,50,60,70,80,90,100)
)
select * from einmaleins
```

#### Hausaufgabe 6
Formulieren Sie folgende Anfragen auf dem bekannten Universitätsschema in SQL.

6.1 Finden Sie die Vorlesungen, für die es keine Studenten gibt.
```sql
select * from vorlesungen v
where v.vorlnr not in(select distinct vorlnr from hoeren)
--Alternative:
select * from vorlesungen v
where not exists (select * from hoeren h where h.vorlnr=v.vorlnr)
```
6.2 Identifizieren Sie alle Studenten, die sich im höchsten Semester befinden.
```sql
select * from studenten s
where s.semester = (select max(semester) from studenten)
-- oder：
select * from studenten s
where not exists (select * from studenten s2 where s2.semester>s.semester)
```

#### Hausaufgabe 7
Formulieren Sie die folgende Anfrage auf dem bekannten Unischema in SQL: Ermitteln Sie für jede Vorlesung, wie viele Studenten diese vorgezogen haben. Ein Student hat eine Vorlesung vorgezogen, wenn er in einem früheren Semester ist als der „Modus“ der Semester der Hörer dieser Vorlesung. Der Modus ist definiert als der Wert, der am häufigsten vorkommt für diese Anfrage also das Semester, in dem die meisten Hörer dieser Vorlesung sind. Falls es mehrere Semester dieser Art gibt, soll nur das niedrigste zählen. Beachten Sie, dass auch Vorlesungen ohne Hörer, sowie Vorlesungen deren Hörer alle im gleichen Semester sind, ausgegeben werden sollen. Geben Sie für jede Vorlesung die Vorlesungsnummer, den Titel und die Anzahl der „Vorzieher“ aus.

```sql
with vorlSemester as(
    select h.vorlnr, s.semester, count(s.semester) as scount 
    from hoeren h, studenten s
    where h.matrnr=s.matrnr 
    group by h.vorlnr, s.semester
), 
vorlModus as(
    select v.vorlnr, min(v.semester) as modus 
    from vorlSemester v
    where v.scount = (select max(scount) from vorlSemester) 
    group by v.vorlnr
)

select v.vorlnr, v.titel, count(s.matrnr) as Vorzieher 
from vorlesungen v 
	left outer join vorlModus m on v.vorlnr=m.vorlnr
	left outer join hoeren h on h.vorlnr=v.vorlnr
	left outer join studenten s on h.matrnr=s.matrnr and s.semester<m.modus
group by v.vorlnr, v.titel
```

#### Hausaufgabe 8
Gegeben sei eine Relation

R : {[A : integer, B : integer, C : integer, D : integer, E : integer]}, die schon sehr viele Daten enthält (Millionen Tupel). 

Sie „vermuten“, dass folgendes gilt:
- a) AB ist ein Superschlüssel der Relation
- b) DE → B
Formulieren Sie SQL-Anfragen, die Ihre Vermutungen bestätigen oder widerlegen.

```sql
/* a) Durch Gruppierung nach A und B kann anhand der Anzahl der Tupel ermittelt werden, ob hier eine Verletzung der Schlüsseleigenschaft vorliegt. Werden also mindestens zwei Tupel mit den gleichen Werten für A und B als Ergebnis ausgegeben, so bildet AB keinen Schlüssel der Relation, ist das Ergebnis der Anfrage jedoch leer, so ist AB ein Superschlüssel. */
select A, B from R
group by A, B
having count(*) > 1;

/* b) In diesem Fall muss nur gelten, dass für alle Tupel, die gleiche Werte in D und E besit- zen, auch die Werte für das Attribut B gleich sind. D.h. wenn nach D und E gruppiert wird, muss die Anzahl der verschiedenen Werte für B kleiner oder gleich 1 sein. Es gilt wieder, dass das Ergebnis der Anfrage alle Tupel enthält, die die Vermutung verletzen. Ist das Ergebnis leer, so gilt DE → B.*/
select D, E from R
group by D, E
having count(distinct B) > 1;
```
