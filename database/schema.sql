--
-- PostgreSQL database dump
--

--
-- Name: ObservationHoraire; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public."ObservationHoraire" (
                                             "dateObservation" timestamp(3) without time zone NOT NULL,
                                             "numPoste" character(8) NOT NULL,
                                             rr1 text,
                                             drr1 text,
                                             hneigef text,
                                             neigetot text,
                                             t double precision,
                                             td text,
                                             htn text,
                                             htx text,
                                             dg text,
                                             t10 text,
                                             t20 text,
                                             t50 text,
                                             t100 text,
                                             tchaussee text,
                                             pstat text,
                                             pmer double precision,
                                             geop text,
                                             pmermin text,
                                             ff text,
                                             dd text,
                                             fxi text,
                                             dxi text,
                                             hxi text,
                                             fxy text,
                                             dxy text,
                                             hxy text,
                                             n text,
                                             nbas text,
                                             cl text,
                                             cm text,
                                             ch text,
                                             c1 text,
                                             c2 text,
                                             c3 text,
                                             c4 text,
                                             vv text,
                                             ww text,
                                             sol text,
                                             solng text,
                                             "uvIndice" text,
                                             alti integer,
                                             b1 text,
                                             b2 text,
                                             b3 text,
                                             b4 text,
                                             chargeneige text,
                                             dd2 text,
                                             dhumec text,
                                             dhumi40 text,
                                             dhumi80 text,
                                             dif text,
                                             dif2 text,
                                             dir text,
                                             dir2 text,
                                             dirhoule text,
                                             dvv200 text,
                                             dxi2 text,
                                             ecoulement text,
                                             esneige text,
                                             etatmer text,
                                             ff2 text,
                                             fxi2 text,
                                             glo text,
                                             glo2 text,
                                             hneigefi1 text,
                                             hneigefi3 text,
                                             hun text,
                                             hux text,
                                             hvague text,
                                             hxi2 text,
                                             infrar text,
                                             infrar2 text,
                                             ins2 text,
                                             lat text,
                                             lon text,
                                             n1 text,
                                             n2 text,
                                             n3 text,
                                             n4 text,
                                             "nomUsuel" text,
                                             pvague text,
                                             tlagon text,
                                             tmer text,
                                             tsneige text,
                                             tsv text,
                                             tvegetaux text,
                                             u text,
                                             un text,
                                             uv text,
                                             uv2 text,
                                             ux text,
                                             vvmer text,
                                             w1 text,
                                             w2 text,
                                             aaaammjjhh integer,
                                             qb1 text,
                                             qb2 text,
                                             qb3 text,
                                             qb4 text,
                                             qc1 text,
                                             qc2 text,
                                             qc3 text,
                                             qc4 text,
                                             qch text,
                                             qchargeneige text,
                                             qcl text,
                                             qcm text,
                                             qdd text,
                                             qdd2 text,
                                             qdg text,
                                             qdhumec text,
                                             qdhumi40 text,
                                             qdhumi80 text,
                                             qdif text,
                                             qdif2 text,
                                             qdir text,
                                             qdir2 text,
                                             qdirhoule text,
                                             qdrr1 text,
                                             qdvv200 text,
                                             qdxi text,
                                             qdxi2 text,
                                             qdxy text,
                                             qecoulement text,
                                             qesneige text,
                                             qetatmer text,
                                             qff text,
                                             qff2 text,
                                             qfxi text,
                                             qfxi2 text,
                                             qfxy text,
                                             qgeop text,
                                             qglo text,
                                             qglo2 text,
                                             qhneigef text,
                                             qhneigefi1 text,
                                             qhneigefi3 text,
                                             qhtn text,
                                             qhtx text,
                                             qhun text,
                                             qhux text,
                                             qhvague text,
                                             qhxi text,
                                             qhxi2 text,
                                             qhxy text,
                                             qinfrar text,
                                             qinfrar2 text,
                                             qins text,
                                             qins2 text,
                                             qn text,
                                             qn1 text,
                                             qn2 text,
                                             qn3 text,
                                             qn4 text,
                                             qnbas text,
                                             qneigetot text,
                                             qpmer integer,
                                             qpmermin text,
                                             qpstat integer,
                                             qpvague text,
                                             qrr1 text,
                                             qsol text,
                                             qsolng text,
                                             qt integer,
                                             qt10 text,
                                             qt100 text,
                                             qt20 text,
                                             qt50 text,
                                             qtchaussee text,
                                             qtd text,
                                             qtlagon text,
                                             qtmer text,
                                             qtn text,
                                             qtn50 text,
                                             qtnsol text,
                                             qtsneige text,
                                             qtsv text,
                                             qtubeneige text,
                                             qtvegetaux text,
                                             qtx text,
                                             qu text,
                                             qun text,
                                             quv text,
                                             quv2 text,
                                             "quvIndice" text,
                                             qux text,
                                             qvv text,
                                             qvvmer text,
                                             qw1 text,
                                             qw2 text,
                                             qww text,
                                             tn text,
                                             tn50 text,
                                             tnsol text,
                                             tubeneige text,
                                             tx text,
                                             "dxi3S" text,
                                             "fxi3S" text,
                                             "hfxi3S" text,
                                             "qdxi3S" text,
                                             "qfxi3S" text,
                                             "qhfxi3S" text,
                                             ins text
);


--
-- Name: Poste; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE IF NOT EXISTS public."Poste" (
                                "numPoste" character(8) NOT NULL,
                                "nomUsuel" text NOT NULL,
                                commune text NOT NULL,
                                "lieuDit" text,
                                "posteOuvert" boolean DEFAULT false NOT NULL,
                                alti integer,
                                datferm timestamp(3) without time zone,
                                datouvr timestamp(3) without time zone,
                                lambx integer,
                                lamby integer,
                                lat double precision NOT NULL,
                                lon double precision NOT NULL,
                                "typePosteActuel" integer
);


--
-- Name: ObservationHoraire ObservationHoraire_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ObservationHoraire"
    ADD CONSTRAINT "ObservationHoraire_pkey" PRIMARY KEY ("numPoste", "dateObservation");


--
-- Name: Poste Poste_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Poste"
    ADD CONSTRAINT "Poste_pkey" PRIMARY KEY ("numPoste");


--
-- Name: ObservationHoraire_dateObservation_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "ObservationHoraire_dateObservation_idx" ON public."ObservationHoraire" USING btree ("dateObservation");


--
-- Name: ObservationHoraire_numPoste_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "ObservationHoraire_numPoste_idx" ON public."ObservationHoraire" USING btree ("numPoste");


--
-- Name: Poste_numPoste_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX IF NOT EXISTS "Poste_numPoste_key" ON public."Poste" USING btree ("numPoste");


--
-- Name: Poste_posteOuvert_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX IF NOT EXISTS "Poste_posteOuvert_idx" ON public."Poste" USING btree ("posteOuvert");


--
-- Name: ObservationHoraire ObservationHoraire_numPoste_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ObservationHoraire"
    ADD CONSTRAINT "ObservationHoraire_numPoste_fkey" FOREIGN KEY ("numPoste") REFERENCES public."Poste"("numPoste") ON UPDATE CASCADE ON DELETE RESTRICT;

