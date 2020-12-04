-- POSTGRESQL!!!

-- pseudo_encrypt and stringify_bigint are the two methods that allow us to generate a random order id with 7
-- uppercase letters from 1 random number

CREATE OR REPLACE FUNCTION pseudo_encrypt(value int) returns int AS $$
DECLARE
l1 int;
l2 int;
r1 int;
r2 int;
i int:=0;
BEGIN
 l1:= (value >> 16) & 65535;
 r1:= value & 65535;
 WHILE i < 3 LOOP
   l2 := r1;
   r2 := l1 # ((((1366 * r1 + 150889) % 714025) / 714025.0) * 32767)::int;
   l1 := l2;
   r1 := r2;
   i := i + 1;
 END LOOP;
 return ((r1 << 16) + l1);
END;
$$ LANGUAGE plpgsql strict immutable;

CREATE OR REPLACE FUNCTION stringify_bigint(n bigint) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT AS $$
DECLARE
 alphabet text:='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 base int:=length(alphabet);
 _n bigint:=abs(n);
 output text:='';
BEGIN
 LOOP
   output := output || substr(alphabet, 1+(_n%base)::int, 1);
   _n := _n / base;
   EXIT WHEN _n=0;
 END LOOP;
 RETURN output;
END $$;

-- initializes all tables

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR,
  last_name VARCHAR,
  student_id VARCHAR
);

DROP TABLE IF EXISTS movie CASCADE;
CREATE TABLE movie (
    id SERIAL PRIMARY KEY,
    name VARCHAR,
    director VARCHAR,
    synopsis VARCHAR,
    photoURL VARCHAR
);

DROP TABLE IF EXISTS theatres CASCADE;
CREATE TABLE theatres (
    id SERIAL PRIMARY KEY,
    capacity INT
);

DROP TABLE IF EXISTS screenings CASCADE;
CREATE TABLE screenings (
    id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES movie,
    theatre INT REFERENCES theatres,
    date DATE,
    attending INT
);

DROP TABLE IF EXISTS orders CASCADE;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  order_id VARCHAR NOT NULL,
  user_id INT REFERENCES users,
  seats VARCHAR,
  screening_id INT REFERENCES screenings,
  order_date TIMESTAMP
);

DROP TABLE IF EXISTS seat_booking CASCADE;
CREATE TABLE seat_booking (
    id SERIAL PRIMARY KEY,
    pos varchar,
    screening INT REFERENCES screenings
);

-- fills database with needed information

INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (4, 'The Santa Clause', 'John Pasquin', 'When a man inadvertently makes Santa fall off of his roof on Christmas Eve, he finds himself magically recruited to take his place.', 'images/santa.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (5, 'Freaky', 'Christopher Landon', 'This November, on Friday the 13th, prepare to get Freaky with a twisted take on the body-swap movie when a teenage girl switches bodies with a relentless serial killer. Seventeen-year-old Millie Kessler (Kathryn Newton, Blockers, HBO''s Big Little Lies) is just trying to survive the bloodthirsty halls of Blissfield High and the cruelty of the popular crowd. But when she becomes the newest target of The Butcher (Vince Vaughn), her town''s infamous serial killer, her senior year becomes the least of her worries. When The Butcher''s mystical ancient dagger causes him and Millie to wake up in each other''s bodies, Millie learns that she has just 24 hours to get her body back before the switch becomes permanent and she''s trapped in the form of a middle-aged maniac forever. The only problem is she now looks like a towering psychopath who''s the target of a city-wide manhunt while The Butcher looks like her and has brought his appetite for carnage to Homecoming. With some help from her friends--ultra-woke Nyla (Celeste O''Connor, Ghostbusters: Afterlife), ultra-fabulous Joshua (Misha Osherovich, The Goldfinch) and her crush Booker (Uriah Shelton, Enter the Warriors Gate)--Millie races against the clock to reverse the curse while The Butcher discovers that having a female teen body is the perfect cover for a little Homecoming killing spree. The film also stars Alan Ruck (Succession), Katie Finneran (Why Women Kill), and Dana Drori (High Fidelity). From the deliciously debased mind of writer-director Christopher Landon (Happy Death Day, the Paranormal Activity franchise) comes a pitch-black horror-comedy about a slasher, a senior, and the brutal truth about high school. Freaky is written by Christopher Landon and Michael Kennedy (Fox''s Bordertown) and is produced by Jason Blum (Halloween, The Invisible Man). The film is produced by Blumhouse Productions in association with Divide/Conquer. The executive producers are Couper Samuelson and Jeanette Volturno.', 'images/freaky.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (10, 'Tenet', 'Christopher Nolan', 'John David Washington is the new Protagonist in Christopher Nolan’s original sci-fi action spectacle “Tenet.” Armed with only one word—Tenet—and fighting for the survival of the entire world, the Protagonist journeys through a twilight world of international espionage on a mission that will unfold in something beyond real time. Not time travel. Inversion. The international cast of “Tenet” also includes Robert Pattinson, Elizabeth Debicki, Dimple Kapadia, Martin Donovan, Fiona Dourif, Yuri Kolokolnikov, Himesh Patel, Clémence Poésy, Aaron Taylor-Johnson, with Michael Caine and Kenneth Branagh.', 'images/tenet.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (2, 'Frozen', 'Jennifer Lee, Chris Buck', 'From the studio behind 2010’s “Tangled” and this year’s “Wreck-It Ralph,” Walt Disney Animation Studios presents “Frozen,” the coolest comedy-adventure ever to hit the big screen. When a prophecy traps a kingdom in eternal winter, Anna (voice of Kristen Bell), a fearless optimist, teams up with extreme mountain man Kristoff and his sidekick reindeer Sven on an epic journey to find Anna’s sister Elsa (voice of Idina Menzel), the Snow Queen, and put an end to her icy spell. Encountering mystical trolls, a funny snowman named Olaf, Everest-like extremes and magic at every turn, Anna and Kristoff battle the elements in a race to save the kingdom from destruction.', 'images/frozen.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (3, 'How The Grinch Stole Christmas', 'Ron Howard, Todd Hallowell ', 'Based on the book by the famous Dr. Seuss. Inside a snowflake exists the magical land of Whoville. In Whoville, live the Who''s, an almost mutated sort of munchkinlike people. All the Who''s love Christmas, yet just outside of their beloved Whoville lives the Grinch. The Grinch is a nasty creature that hates Christmas, and plots to steal it away from the Whos which he equally abhors. Yet a small child, Cindy Lou Who, decides to try befriend the Grinch.', 'images/grinch.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (6, 'Wonder Woman 1984', 'Patty Jenkins, Dan Bradley', 'Fast forward to the 1980s as Wonder Woman''s (Gal Gadot) next big screen adventure finds her facing an all-new foe: The Cheetah (Kristen Wiig).', 'images/wonderwoman.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (8, 'Let Him Go', 'Thomas Bezucha', 'Following the loss of their son, retired sheriff George Blackledge (Costner) and his wife Margaret (Lane) leave their Montana ranch to rescue their young grandson from the clutches of a dangerous family living off the grid in the Dakotas, headed by matriarch Blanche Weboy. When they discover the Weboys have no intention of letting the child go, George and Margaret are left with no choice but to fight for their family.', 'images/lethimgo.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (7, 'All My Life', 'Marc Meyers', 'A couple''s wedding plans are thrown off course when the groom is diagnosed with liver cancer.', 'images/life.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (9, 'Come Play', 'Jacob Chase', 'Newcomer Azhy Robertson stars as Oliver, a lonely young boy who feels different from everyone else. Desperate for a friend, he seeks solace and refuge in his ever-present cell phone and tablet. When a mysterious creature uses Oliver’s devices against him to break into our world, Oliver’s parents (Gillian Jacobs and John Gallagher Jr.) must fight to save their son from the monster beyond the screen. The film is produced by The Picture Company for Amblin Partners.', 'images/comeplay.jpg');
INSERT INTO movie (id, name, director, synopsis, photourl) VALUES (1, 'The Croods: A New Age', 'Chris Sanders, Kirk DeMicco, Joel Crawford, Kathryn Alsman', 'The Croods have survived their fair share of dangers and disasters, from fanged prehistoric beasts to surviving the end of the world, but now they will face their biggest challenge of all: another family. The Croods need a new place to live. So, the first prehistoric family sets off into the world in search of a safer place to call home. When they discover an idyllic walled-in paradise that meets all their needs, they think their problems are solved … except for one thing. Another family already lives there: the Bettermans. The Bettermans (emphasis on the “better”)—with their elaborate tree house, amazing inventions and irrigated acres of fresh produce—are a couple of steps above the Croods on the evolutionary ladder. When they take the Croods in as the world’s first houseguests, it isn’t long before tensions escalate between the cave family and the modern family. Just when all seems lost, a new threat will propel both families on an epic adventure outside the safety of the wall, one that will force them to embrace their differences, draw strength from each other and forge a future together. The Croods: A New Age features the voice talent of returning stars Nicolas Cage as Grug Crood, Catherine Keener as Ugga Crood, Emma Stone as their daughter, Eep; Ryan Reynolds as Eep’s boyfriend, Guy; Clark Duke (Hot Tub Time Machine) as Thunk and Cloris Leachman as Gran. They’re joined by new stars Peter Dinklage (HBO’s Game of Thrones) as Phil Betterman, Leslie Mann (Blockers) as Hope Betterman, and Kelly Marie Tran (Star Wars: Episode VIII-The Last Jedi) as their daughter, Dawn. The film is directed by Joel Crawford, who has worked on multiple DreamWorks Animation films, including Trolls and the Kung Fu Panda franchise, and is produced by Mark Swift (Captain Underpants: The First Epic Movie, Madagascar 3: Europe’s Most Wanted).', 'images/croods.jpg');

INSERT INTO theatres (id, capacity) VALUES (1, 100);
INSERT INTO theatres (id, capacity) VALUES (2, 100);
INSERT INTO theatres (id, capacity) VALUES (3, 100);
INSERT INTO theatres (id, capacity) VALUES (4, 100);
INSERT INTO theatres (id, capacity) VALUES (5, 100);

INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (41, 4, 4, '2020-12-01 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (44, 5, 5, '2020-12-01 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (43, 4, 4, '2020-12-01 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (53, 8, 3, '2020-12-02 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (35, 2, 2, '2020-12-01 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (59, 10, 5, '2020-12-02 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (32, 1, 1, '2020-12-01 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (33, 1, 1, '2020-12-01 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (34, 1, 1, '2020-12-01 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (36, 2, 2, '2020-12-01 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (37, 2, 2, '2020-12-01 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (38, 3, 3, '2020-12-01 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (39, 3, 3, '2020-12-01 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (40, 3, 3, '2020-12-01 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (42, 4, 4, '2020-12-01 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (45, 5, 5, '2020-12-01 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (46, 5, 5, '2020-12-01 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (47, 6, 1, '2020-12-02 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (48, 6, 1, '2020-12-02 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (49, 6, 1, '2020-12-02 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (50, 7, 2, '2020-12-02 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (51, 7, 2, '2020-12-02 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (52, 7, 2, '2020-12-02 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (54, 8, 3, '2020-12-02 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (55, 8, 3, '2020-12-02 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (56, 9, 4, '2020-12-02 17:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (57, 9, 4, '2020-12-02 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (58, 9, 4, '2020-12-02 22:30:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (60, 10, 5, '2020-12-02 20:00:00.000000', 0);
INSERT INTO screenings (id, movie_id, theatre, date, attending) VALUES (61, 10, 5, '2020-12-02 22:30:00.000000', 0);