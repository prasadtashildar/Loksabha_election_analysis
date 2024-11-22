
--------LOKSHABA ELECTION 2024-----------------------
--Total Seats
SELECT 
	DISTINCT COUNT (Parliament_Constituency) AS Total_Seats
	FROM election.dbo.constituencywise_results

	--What is the total number of seats available for elections in each state
SELECT 
	 count(cr.constituency_id),sr.state
	FROM election.dbo.constituencywise_results cr
	join election.dbo.statewise_results as sr
	ON sr.Parliament_Constituency=cr.Parliament_Constituency
	GROUP BY sr.state
	order by sr.state

	--Total Seats Won by NDA Alliance
SELECT 
    SUM(CASE 
            WHEN party IN (
                'Bharatiya Janata Party - BJP', 
                'Telugu Desam - TDP', 
				'Janata Dal  (United) - JD(U)',
                'Shiv Sena - SHS', 
                'AJSU Party - AJSUP', 
                'Apna Dal (Soneylal) - ADAL', 
                'Asom Gana Parishad - AGP',
                'Hindustani Awam Morcha (Secular) - HAMS', 
                'Janasena Party - JnP', 
				'Janata Dal  (Secular) - JD(S)',
                'Lok Janshakti Party(Ram Vilas) - LJPRV', 
                'Nationalist Congress Party - NCP',
                'Rashtriya Lok Dal - RLD', 
                'Sikkim Krantikari Morcha - SKM'
            ) THEN won
            ELSE 0 
        END) AS NDA_Total_Seats_Won
FROM 
    election.dbo.partywise_results


--Seats Won by NDA Alliance Parties.
select party,won 
from election.dbo.partywise_results
where party not in (  'Bharatiya Janata Party - BJP', 
        'Telugu Desam - TDP', 
		'Janata Dal  (United) - JD(U)',
        'Shiv Sena - SHS', 
        'AJSU Party - AJSUP', 
        'Apna Dal (Soneylal) - ADAL', 
        'Asom Gana Parishad - AGP',
        'Hindustani Awam Morcha (Secular) - HAMS', 
        'Janasena Party - JnP', 
		'Janata Dal  (Secular) - JD(S)',
        'Lok Janshakti Party(Ram Vilas) - LJPRV', 
        'Nationalist Congress Party - NCP',
        'Rashtriya Lok Dal - RLD', 
        'Sikkim Krantikari Morcha - SKM'
    
)order by won desc

--Add new column field in table partywise_results to get the Party Alliance as NDA, I.N.D.I.A and OTHER
alter table election.dbo.partywise_results
add party_alliance varchar(50)

update  election.dbo.partywise_results
set party_alliance='INDIA'
where party in('Indian National Congress - INC',
    'Aam Aadmi Party - AAAP',
    'All India Trinamool Congress - AITC',
    'Bharat Adivasi Party - BHRTADVSIP',
    'Communist Party of India  (Marxist) - CPI(M)',
    'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
    'Communist Party of India - CPI',
    'Dravida Munnetra Kazhagam - DMK',	
    'Indian Union Muslim League - IUML',
    'Jammu & Kashmir National Conference - JKN',
    'Jharkhand Mukti Morcha - JMM',
    'Kerala Congress - KEC',
    'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
    'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
    'Rashtriya Janata Dal - RJD',
    'Rashtriya Loktantrik Party - RLTP',
    'Revolutionary Socialist Party - RSP',
    'Samajwadi Party - SP',
    'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
    'Viduthalai Chiruthaigal Katchi - VCK'
)
UPDATE election.dbo.partywise_results
SET party_alliance = 'NDA'
WHERE party IN (
    'Bharatiya Janata Party - BJP',
    'Telugu Desam - TDP',
    'Janata Dal  (United) - JD(U)',
    'Shiv Sena - SHS',
    'AJSU Party - AJSUP',
    'Apna Dal (Soneylal) - ADAL',
    'Asom Gana Parishad - AGP',
    'Hindustani Awam Morcha (Secular) - HAMS',
    'Janasena Party - JnP',
    'Janata Dal  (Secular) - JD(S)',
    'Lok Janshakti Party(Ram Vilas) - LJPRV',
    'Nationalist Congress Party - NCP',
    'Rashtriya Lok Dal - RLD',
    'Sikkim Krantikari Morcha - SKM'
);
UPDATE election.dbo.partywise_results
SET party_alliance = 'OTHER'
WHERE party_alliance IS NULL;


select party_alliance,sum(won) as seats from election.dbo.partywise_results
group by party_alliance
order by seats desc

--Winning candidate's name, their party name, total votes, and the margin of victory for a specific state and constituency?

select c.candidate,c.party,sr.State,sr.Constituency,cr.total_votes,cr.margin
from election.dbo.constituencywise_details as c
join election.dbo.constituencywise_results as cr
on cr.Constituency_ID=c.Constituency_ID
join election.dbo.statewise_results sr
on sr.Parliament_Constituency=cr.Parliament_Constituency


--Which parties won the most seats in s State, and how many seats did each party win?
SELECT 
    p.Party,
    COUNT(cr.Constituency_ID) AS Seats_Won
FROM 
    election.dbo.constituencywise_results cr
JOIN 
    election.dbo.partywise_results p ON cr.Party_ID = p.Party_ID
JOIN 
    election.dbo.statewise_results sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
JOIN election.dbo.states s ON sr.State_ID = s.State_ID
WHERE 
    s.state = 'Gujarat'
GROUP BY 
    p.Party
ORDER BY 
    Seats_Won DESC;


--What is the total number of seats won by each party alliance (NDA, I.N.D.I.A, and OTHER) in each state for the India Elections 2024--
SELECT 
    s.state as state_name,
	sum( case when p.party_alliance='NDA' then 1 else 0 end)as NDA_Seats,
	 sum( case when p.party_alliance='INDIA' then 1 else 0 end)as INDIA_Seats,
	  sum( case when p.party_alliance='OTHER' then 1 else 0 end)as OTHER_Seats
    
FROM 
    election.dbo.constituencywise_results cr
JOIN 
    election.dbo.partywise_results p ON cr.Party_ID = p.Party_ID
JOIN 
    election.dbo.statewise_results sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
JOIN election.dbo.states s ON sr.State_ID = s.State_ID
WHERE 
    p.party_alliance in('NDA','INDIA','OTHER')
GROUP BY 
    s.state
ORDER BY 
     s.state DESC;


--Which candidate received the highest number of EVM votes in each constituency (Top 10)?

select 
cr.Constituency_Name,cr.Constituency_ID,cr.Winning_Candidate,cd.EVM_Votes
from election.dbo.constituencywise_details cd
join election.dbo.constituencywise_results cr
on cr.Constituency_ID=cd.Constituency_ID
order by cd.EVM_Votes desc


--Which candidate won and which candidate was the runner-up in each constituency of State for the 2024 elections?
with cte as(
select 
(cr.Constituency_Name)
,cr.Constituency_ID,cd.candidate as candidatee,
cd.EVM_Votes
,ROW_NUMBER()over(partition by cr.Constituency_ID order by cd.EVM_Votes desc)as Voterank
from election.dbo.constituencywise_details cd
join election.dbo.constituencywise_results cr
on cr.Constituency_ID=cd.Constituency_ID
JOIN 
    election.dbo.partywise_results p ON cr.Party_ID = p.Party_ID
JOIN 
    election.dbo.statewise_results sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
JOIN election.dbo.states s ON sr.State_ID = s.State_ID
where s.state='Maharashtra')
SELECT 
ct.Constituency_Name,
max(case when ct.Voterank=1 then ct.candidatee end) as winning_candidate,
 max(case when ct.Voterank=2 then ct.candidatee end) as losing_candidate
FROM cte ct
--ct.Constituency_Name='sangli'
GROUP BY 
    ct.Constituency_Name
ORDER BY 
    ct.Constituency_Name;
where 
