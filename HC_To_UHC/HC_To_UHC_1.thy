theory HC_To_UHC_1
  imports Main Definitions_UHC
begin


subsection\<open>G \<in> hc --> hc_to_uhc G \<in> uhc\<close>

fun to_cycle_uhc::"('a, ('a \<times> 'a)) pre_digraph \<Rightarrow> 'a list \<Rightarrow> ('a \<times> nat) list" where
"to_cycle_uhc G [] = []" |
"to_cycle_uhc G (v#vs) = [(v, 0), (v, 1), (v, 2)] @ to_cycle_uhc G vs"

context
  fixes G assumes in_hc: "G \<in> hc" "card (verts G) > 1" 
  fixes Cycle assumes Cycle_def: "is_hc G Cycle"
  fixes G' assumes G'_def: "G' = hc_to_uhc G"
  fixes Cy assumes Cy_def: "Cy = (hd Cycle, 2) # to_cycle_uhc G (tl Cycle)"
begin

lemma G'_def_2:
  shows "G' = \<lparr>verts = {(v, (0::nat))|v. v \<in> verts G} \<union> {(v, 1)|v. v \<in> verts G} \<union> {(v, 2)|v. v \<in> verts G}, 
    arcs = {((v, 0), (v, 1))|v. v \<in> verts G} \<union>{((v, 1), (v, 0))|v. v \<in> verts G}\<union>
          {((v, 1), (v, 2))|v. v \<in> verts G}\<union>{((v, 2), (v, 1))|v. v \<in> verts G}\<union>
          {((v, 2), (u, 0))|v u e. e \<in> arcs G \<and> v = tail G e \<and> u = head G e \<and> u \<noteq> v}\<union> 
          {((u, 0), (v, 2))|v u e. e \<in> arcs G \<and> v = tail G e \<and> u = head G e \<and> u \<noteq> v},
    tail = fst, head = snd\<rparr>"
proof -
  have "wf_digraph G" "((tail G = fst \<and> head G = snd) \<or> arcs G = {})"
    using in_hc hc_def by auto
  then show ?thesis  using in_hc 
    by(auto simp add:  G'_def hc_to_uhc_def)
qed


lemma wf_digraph_G:
  shows "wf_digraph G" "((tail G = fst \<and> head G = snd) \<or> arcs G = {})"
  using in_hc hc_def by auto


lemma finite_verts_G:
  shows "finite (verts G)" 
  using in_hc hc_def by auto

lemma wf_digraph_G': 
  shows "wf_digraph G'"
  using G'_def_2 wf_digraph_def wf_digraph_G by(auto simp add: G'_def_2 wf_digraph_def)


lemma arc_to_ends_G': 
  shows "arc_to_ends G' e = e"
  using arc_to_ends_def G'_def_2
  by (simp add: arc_to_ends_def) 

lemma arcs_ends_G': 
  shows "arcs_ends G' = arcs G'"
  using arcs_ends_def arc_to_ends_G'
  by(auto simp add: arcs_ends_def arc_to_ends_G')


lemma sym_arcs_G': 
  shows "sym (arcs G')"
  unfolding G'_def_2 sym_def by(auto)   


lemma symmetric_G': 
  shows "symmetric G'"
  using symmetric_def arcs_ends_G' sym_arcs_G' by fastforce   


lemma head_tail_G': 
  shows "head G' = snd" "tail G' = fst"
  using G'_def_2 by auto 


lemma Cycle_subset:
  shows "set Cycle \<subseteq> verts G"
  using Cycle_def is_hc_def by metis


lemma Cycle_not_empty:
  assumes  "card (verts G) > 1"
  shows "Cycle \<noteq> []"
  using Cycle_def is_hc_def 
  by (metis assms leD vwalk_arcs.simps(1) wf_digraph.cycle_conv wf_digraph_G(1)) 


lemma last_pre_digraph_cas: 
  assumes "pre_digraph.cas G u (p) v" "p\<noteq> []" "arcs G \<noteq> {}"
  shows "snd (last p) = v"
  using assms proof(induction p arbitrary: u)
  case Nil
  then show ?case by simp 
next
  case (Cons a p)
  then show ?case proof(cases "p = []")
    case True
    then have 0: "last (a#p) = a" 
      by simp
    then have "pre_digraph.cas G u (a#p)  v = 
      (tail G a = u \<and> pre_digraph.cas G (head G a) [] v)"
      using True 
      by (simp add: pre_digraph.cas.simps(2)) 
    then have 1: "pre_digraph.cas G (head G a) [] v"
      using Cons by auto
    then have 2: "pre_digraph.cas G (head G a) [] v = 
      ((head G a) = v)" 
      using pre_digraph.cas.simps  by fast 
    then have "head G a = snd a" 
      using wf_digraph_G assms 
      by (auto)
    then show ?thesis 
      using 0 1 2 by simp
  next
    case False
    then have 0: "last (a#p) = last p" 
      by simp
    have "pre_digraph.cas G u (a#p)  v = 
      (tail G a = u \<and> pre_digraph.cas G (head G a) p v)"
      by (simp add: pre_digraph.cas.simps(2)) 
    then have "pre_digraph.cas G (head G a) p v"
      using Cons by auto
    then have " snd (last p) = v" 
      using Cons False by simp 
    then show ?thesis 
      using 0 by auto 
  qed
qed 

lemma hd_pre_digraph_cas: 
  assumes "pre_digraph.cas G u (p) v" "p\<noteq> []" "arcs G \<noteq> {}"
  shows "fst (hd p) = u"
  using assms proof(induction p arbitrary: u)
  case Nil
  then show ?case by simp 
next
  case (Cons a p)
  then have "pre_digraph.cas G u (a#p)  v = 
      (tail G a = u \<and> pre_digraph.cas G (head G a) p v)"
    by (simp add: pre_digraph.cas.simps(2))
  then have "tail G a = u" 
    using Cons 
    by simp
  then have "fst a = u" 
    using wf_digraph_G assms 
    by auto
  then show ?case by simp
qed 


lemma hd_last_Cycle:
  assumes "card (verts G) > 1" "arcs G \<noteq> {}"
  shows "hd Cycle = last Cycle" 
proof (cases "length Cycle = 1")
  case True
  then show ?thesis 
    using True assms Cycle_not_empty
    by (metis List.finite_set assms(1) card_length contains_two_card_greater_1 last_in_set leD list.set_sel(1))  
next
  case False
  have "Cycle \<noteq> []"
    using assms Cycle_not_empty by blast
  then have "length Cycle \<noteq> 1" "length Cycle \<noteq> 0" 
    using assms False by(auto)
  then have "length Cycle \<ge> 2" 
    by linarith  
  then have arcs_not_epmty: "(vwalk_arcs Cycle) \<noteq> []" 
    using vwalk_arcs_empty_length_p by force
  have "\<exists>u. pre_digraph.awalk G u (vwalk_arcs Cycle) u" 
    using Cycle_def is_hc_def pre_digraph.cycle_def assms 
    by (metis antisym less_imp_le_nat nat_neq_iff)
  then obtain u where u_def: "pre_digraph.awalk G u (vwalk_arcs Cycle) u" 
    by auto
  then have 1: "pre_digraph.cas G u (vwalk_arcs Cycle) u" 
    using pre_digraph.awalk_def by force
  then have "snd (last (vwalk_arcs Cycle)) = u" 
    using arcs_not_epmty last_pre_digraph_cas assms
    by auto 
  then have 2: "last Cycle = u" 
    using assms last_vwalk_arcs_last_p arcs_not_epmty assms 
    by simp
  have "fst (hd (vwalk_arcs Cycle)) = u" 
    using arcs_not_epmty hd_pre_digraph_cas 1 assms
    by auto
  then have 3: "hd Cycle = u" 
    using hd_vwalk_arcs_last_p assms arcs_not_epmty 
    by simp
  then show ?thesis using 2 3 
    by simp
qed


lemma finite_subset_verts_G':
  shows "finite {(v, i) |v. v \<in> verts G}"
   using finite_verts_G by simp 


lemma distinct_tail_cycle: 
  shows "distinct (tl Cycle)" 
  using Cycle_def is_hc_def by auto


lemma finite_verts_G':
  shows "finite (verts G')" 
  using G'_def_2 finite_verts_G finite_subset_verts_G' 
  by fastforce


lemma vwalk_arcs_Cycle_subseteq_arcs_G:
  assumes "card (verts G) > 1"
  shows "set (vwalk_arcs Cycle) \<subseteq> arcs G" 
proof -
  have "pre_digraph.cycle G (vwalk_arcs Cycle)" 
    using Cycle_def is_hc_def assms 
    by force
  then have "\<exists>u. pre_digraph.awalk G u (vwalk_arcs Cycle) u" 
    using pre_digraph.cycle_def 
    by metis
  then obtain u where "pre_digraph.awalk G u (vwalk_arcs Cycle) u" 
    by auto
  then show ?thesis 
    using  pre_digraph.awalk_def 
    by fast
qed


lemma no_arcs_impl_at_most_one_vertex: 
  assumes "arcs G = {}"
  shows "card (verts G) \<le> 1" 
proof (rule ccontr)
  assume "\<not> card (verts G) \<le> 1"
  then have a1: "card (verts G) > 1" 
    by auto
  then have "pre_digraph.cycle G (vwalk_arcs Cycle)" 
    using is_hc_def a1 Cycle_def
    by force
  then have "\<exists>u. pre_digraph.awalk G u (vwalk_arcs Cycle) u" 
    using pre_digraph.cycle_def 
    by metis
  then obtain u where "pre_digraph.awalk G u (vwalk_arcs Cycle) u" 
    by auto
  then have "set (vwalk_arcs Cycle) \<subseteq> arcs G"
    using  pre_digraph.awalk_def 
    by fast
  then have "set (vwalk_arcs Cycle) = {}"
    using assms by simp
  then have "vwalk_arcs Cycle = []"
    by simp
  then have "length Cycle \<le> 1" 
    using vwalk_arcs_empty_length_p by auto 
  then have cy1: "card (set Cycle) \<le> 1" "finite (set Cycle)"
    using card_length dual_order.trans apply(blast) by auto
  then have "card (verts G) \<le> 1"
  proof -
    have 1: "\<forall>x \<in> verts G. x \<in> set Cycle"
      using Cycle_def a1 is_hc_def by force
    then have "finite (verts G)" 
      using cy1 a1 card_eq_0_iff by fastforce  
    then have "card (verts G) = card (set Cycle)" 
      using 1 cy1 
      by (meson a1 card_greater_1_contains_two_elements contains_two_card_greater_1 dual_order.strict_trans1 less_numeral_extra(4)) 
    then show ?thesis using cy1 by simp
  qed
  then show False using a1 by auto
qed




lemma awalk_verts_Cycle_one_node: 
  assumes "a = [((v, 0), (v, 1)), ((v, 1), (v, 2)), ((v, 2), (v, 0))]"
  shows "(pre_digraph.awalk_verts G' (v, 0) a) = [(v, 0), (v, 1), (v, 2), (v, 0)]"
  using assms using G'_def_2 by(auto simp add: pre_digraph.awalk_verts.simps)



lemma cas_verts_Cycle_one_node: 
  shows "pre_digraph.cas G' (v, 0) [((v, 0), v, Suc 0), ((v, Suc 0), v, 2), ((v, 2), v, 0)] (v, 0)"
  using G'_def_2 by(auto simp add: pre_digraph.cas.simps) 


lemma awalk_Cycle_one_node: 
  assumes "a = [((v, 0), (v, 1)), ((v, 1), (v, 2)), ((v, 2), (v, 0))]"  
    "verts G' = {(v, 0), (v, 1), (v, 2)}" "((v, 0), (v, 1)) \<in> arcs G'" "((v, 1), (v, 2)) \<in> arcs G'" "((v, 2), (v, 0))\<in> arcs G'"
  shows "(pre_digraph.awalk G' (v, 0) a (v, 0))"
  unfolding pre_digraph.awalk_def using assms by(simp add: cas_verts_Cycle_one_node)


lemma arcs_G'_subset_verts_verts: 
  shows "arcs G' \<subseteq> (verts G' \<times> verts G')" 
  by (simp add: arcs_ends_G' subrelI wf_digraph.adj_in_verts(1) wf_digraph.adj_in_verts(2) wf_digraph_G') 



lemma arcsG_empty_exists_cycleG':
  assumes "arcs G = {}" 
  shows "\<exists>Cy. is_uhc G' Cy"
proof -
  have "card (verts G) \<le> 1"
    using no_arcs_impl_at_most_one_vertex assms 
    by simp
  then show ?thesis using in_hc by auto
qed


lemma non_empty_arcs_card_verts_G: 
  assumes "arcs G \<noteq> {}"
  shows "card (verts G) \<ge> 1"
proof -
  have "\<exists>u v. (u, v) \<in> arcs G" 
    using assms by auto
  then obtain u v where uv_def:
    "(u, v) \<in> arcs G"
    by auto
  then have "u \<in> verts G" 
    using wf_digraph_G wf_digraph_def 
    by fastforce
  then show ?thesis
    using card_0_eq finite_verts_G by fastforce 
qed


lemma card_verts_G':
  assumes "card (verts G) \<ge> 1"
  shows "card (verts G') \<ge> 1"
proof -
  have "\<exists>v. v \<in> verts G" 
    using assms not_one_le_zero by fastforce 
  then obtain v where "v \<in> verts G"
    by auto
  then have "(v, 0) \<in> verts G'"
    using G'_def_2 by auto
  then show ?thesis
    using finite_verts_G' 
    by (metis One_nat_def Suc_leI card_gt_0_iff empty_iff)
qed


lemma card_verts_G'_2:
  assumes "card (verts G) > 1"
  shows "card (verts G') > 1"
proof -
  have "\<exists>v. v \<in> verts G" 
    using assms not_one_le_zero by fastforce 
  then obtain v where "v \<in> verts G"
    by auto
  then have "(v, 0) \<in> verts G'" "(v, 1) \<in> verts G'"
    using G'_def_2 by auto
  then show ?thesis
    using finite_verts_G' 
    by (meson contains_two_card_greater_1 prod.inject zero_neq_one) 
qed


lemma not_in_cycle_not_in_uhc_cycle: 
  assumes "a \<notin> set C"
  shows "(a, i) \<notin> set (to_cycle_uhc G C)"
  using assms apply(induction C) by(auto)


lemma distinct_C_distinct_uhc_cycle: 
  assumes "distinct C" 
  shows "distinct (to_cycle_uhc G C)"
  using assms proof(induction C)
  case Nil
  then show ?case by simp
next
  case (Cons a C)
  have "to_cycle_uhc G (a # C) = [(a, (0::nat)), (a, 1), (a, 2)] @ to_cycle_uhc G C"
    by simp
  have 1: "distinct (to_cycle_uhc G C)"
    using Cons by simp
  have 2: "distinct [(a, (0::nat)), (a, 1), (a, 2)]"
    by(auto) 
  have "(a, 0) \<notin> set (to_cycle_uhc G C)" "(a, 1) \<notin> set (to_cycle_uhc G C)" "(a, 2) \<notin> set (to_cycle_uhc G C)"
    using not_in_cycle_not_in_uhc_cycle Cons
    by auto 
  then show ?case 
    using 1 2 by auto
qed



lemma distinct_Cy: 
  shows "distinct (tl Cy)"
proof -
  have "tl Cy = to_cycle_uhc G (tl Cycle)" 
    using Cy_def by auto
  then show ?thesis
    using distinct_tail_cycle distinct_C_distinct_uhc_cycle
    by presburger

qed


lemma subset_G_to_uhc_subset_G': 
  assumes "set C \<subseteq> verts G"
  shows "set (to_cycle_uhc G C) \<subseteq> verts G'"
  using assms proof(induction C)
  case Nil
  then show ?case by simp
next
  case (Cons a C)
  then have a_in_verts: "a \<in> verts G" 
    by simp
  have "to_cycle_uhc G (a # C) = [(a, (0::nat)), (a, 1), (a, 2)] @ to_cycle_uhc G C"
    by simp
  have 1: "set [(a, (0::nat)), (a, 1), (a, 2)] \<subseteq> verts G'"
    using G'_def_2 a_in_verts by auto
  have 2: "set (to_cycle_uhc G C) \<subseteq> verts G'"
    using Cons by simp
  then show ?case using 1 by simp
qed



lemma set_Cy_subset_G': 
  assumes  "card (verts G) > 1"
  shows "set Cy \<subseteq> verts G'" 
proof -
  have 0: "Cy = (hd Cycle, 2) # to_cycle_uhc G (tl Cycle)"
    using Cy_def by simp
  then have 1: "set (to_cycle_uhc G (tl Cycle)) \<subseteq> verts G'"  
    using Cycle_subset subset_G_to_uhc_subset_G'    
    by (meson list_set_tl subset_code(1)) 
  have "hd Cycle \<in> verts G"
    using Cycle_subset Cycle_not_empty assms by auto 
  then have "(hd Cycle, 2) \<in> verts G'"
    using G'_def_2 
    by fastforce
  then show ?thesis 
    using 1 0 by auto  
qed


lemma x_in_C_impl_x_in_to_cycle_uhc_0: 
  assumes "x \<in> set C"
  shows "(x, 0) \<in> set (to_cycle_uhc G C)" 
  using assms proof(induction C)
  case Nil
  then show ?case by simp
next
  case (Cons a C)
  then show ?case proof(cases "x = a")
    case True
    then show ?thesis by auto
  next
    case False
    then show ?thesis using Cons by auto
  qed
qed

lemma x_in_C_impl_x_in_to_cycle_uhc_1: 
  assumes "x \<in> set C"
  shows "(x, 1) \<in> set (to_cycle_uhc G C)" 
  using assms proof(induction C)
  case Nil
  then show ?case by simp
next
  case (Cons a C)
  then show ?case proof(cases "x = a")
    case True
    then show ?thesis by auto
  next
    case False
    then show ?thesis using Cons by auto
  qed
qed

lemma x_in_C_impl_x_in_to_cycle_uhc_2: 
  assumes "x \<in> set C"
  shows "(x, 2) \<in> set (to_cycle_uhc G C)" 
  using assms proof(induction C)
  case Nil
  then show ?case by simp
next
  case (Cons a C)
  then show ?case proof(cases "x = a")
    case True
    then show ?thesis by auto
  next
    case False
    then show ?thesis using Cons by auto
  qed
qed


lemma card_verts_impl_length_Cycle: 
  assumes "card (verts G) > 1"  "arcs G \<noteq> {}"
  shows "length Cycle > 2" 
  using assms proof -
  have hl: "hd Cycle = last Cycle"
    using assms 
    by (simp add: local.hd_last_Cycle) 
  obtain u v where 1: "u \<in> verts G" "v \<in> verts G" "u \<noteq> v"
    using assms 
    using card_greater_1_contains_two_elements by blast 
  then have "u \<in> set Cycle" "v \<in> set Cycle"
    using Cycle_def assms is_hc_def by fastforce+
  then have "u \<in> set (tl Cycle)" "v \<in> set (tl Cycle)"
    using hl 
    by (metis "1"(3) Cycle_not_empty List.insert_def hd_Cons_tl in_hc(2) in_set_insert insert_Nil last_ConsR last_in_set list.distinct(1) list.sel(1) list.sel(3) list.set_cases)+ 
  then have "card (set (tl Cycle)) > 1" 
    using 1 
    by (meson List.finite_set contains_two_card_greater_1) 
  then have "length (tl Cycle) > 1" 
    by (metis \<open>u \<in> set (tl Cycle)\<close> card_length leD length_pos_if_in_set less_numeral_extra(3) less_one linorder_neqE_nat) 
  then show ?thesis by simp
qed


lemma all_verts_G'_in_Cy: 
  assumes  "card (verts G) > 1" "arcs G \<noteq> {}"
  shows "(\<forall>x\<in>verts G'. x \<in> set Cy)"
proof 
  fix x assume x_in: "x \<in> verts G'"
  then have "(\<exists>a. x = (a, 0)) \<or> (\<exists>a. x = (a, 1)) \<or> (\<exists>a. x = (a, 2))"
    using G'_def_2 by auto
  then have "(\<exists>a. x = (a, 0) \<or> x = (a, 1) \<or>  x = (a, 2))"
    by fastforce
  then obtain a where a_def: "x = (a, 0) \<or> x = (a, 1) \<or>  x = (a, 2)"
    by auto
  then have "a \<in> verts G" 
    using G'_def_2  x_in 
    by force
  then have a_in_Cycle: "a \<in> set Cycle"
    using Cycle_def assms(1) is_hc_def by fastforce 
  then have "a \<in> set (tl Cycle)"
  proof (cases "a = hd Cycle")
    case True
    then have 1: "a = last Cycle"
      using hd_last_Cycle assms by blast
    then show ?thesis using 1 card_verts_impl_length_Cycle assms last_in_set_tl 
      by fastforce
  next
    case False
    then show ?thesis using a_in_Cycle 
      by (metis Cycle_not_empty assms(1) hd_Cons_tl set_ConsD)  
  qed 
  then have "(a, 0) \<in> set ( to_cycle_uhc G (tl Cycle))"
      "(a, 1) \<in> set ( to_cycle_uhc G (tl Cycle))"
      "(a, 2) \<in> set ( to_cycle_uhc G (tl Cycle))"
    using x_in_C_impl_x_in_to_cycle_uhc_0 x_in_C_impl_x_in_to_cycle_uhc_1 x_in_C_impl_x_in_to_cycle_uhc_2 by auto
  then show "x\<in> set Cy"  using a_def Cy_def by force
qed


lemma c_not_empty_to_cycle_not_empty: 
  assumes "C \<noteq> []"
  shows "to_cycle_uhc G C \<noteq> []"
  using assms apply(induction C) by(auto)


lemma last_to_cycle_uhc: 
  assumes "C \<noteq> []"
  shows "last (to_cycle_uhc G C) = (last C, 2)"
  using assms proof(induction C)
  case Nil
  then show ?case by simp
next
  case (Cons a C)
  then show ?case proof(cases "C = []")
    case True
    then show ?thesis by simp
  next
    case False
    then have 1: "last (to_cycle_uhc G C) = (last C, 2)"
      using Cons by simp
    have 2: "last (a#C) = last C"
      using False by simp
    have "(to_cycle_uhc G C) \<noteq> []"
      using False c_not_empty_to_cycle_not_empty by simp 
    then have 3: "last (to_cycle_uhc G (a#C)) = last (to_cycle_uhc G C)"
      using False by auto 
    then show ?thesis using Cons 1 2 3 by auto   
  qed
qed


lemma hd_last_Cy: 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "hd Cy = last Cy"
proof -
  have 1: "hd Cycle = last Cycle" 
    using hd_last_Cycle assms by blast
  have 2: "Cycle \<noteq> []" 
    using assms Cycle_not_empty by blast 
  then show ?thesis proof(cases "length Cycle = 1")
    case True
    then have "tl Cycle = []"
      by (metis length_1_set_L list.sel(2) list.sel(3) list.set_sel(1)) 
    then have "Cy = [(hd Cycle, 2)]" 
      using Cy_def by simp
    then show ?thesis by simp
  next
    case False
    then have "length Cycle > 1" 
      using 1  2 
      by (simp add: nat_neq_iff) 
    then have 3: "tl Cycle \<noteq> []" 
      by (metis length_tl less_numeral_extra(3) list.size(3) zero_less_diff) 
    then have 4: "hd Cycle = last (tl Cycle)"
      using 1 
      by (simp add: last_tl) 
    have 5: "last Cycle = last (tl Cycle)" 
      using 1 
      using "4" by auto 
    have 6: "last (to_cycle_uhc G (tl Cycle)) = (last (tl Cycle), 2)" 
      using 3 last_to_cycle_uhc by(auto simp add:3 last_to_cycle_uhc)  
    have "(to_cycle_uhc G (tl Cycle)) \<noteq> []" 
      by (simp add: "3" c_not_empty_to_cycle_not_empty) 
    then have "last Cy =  (last (tl Cycle), 2)"
      using 6 Cy_def by auto
    then have "last Cy = (last Cycle, 2)"
      using 5 by simp 
    then have 7: "last Cy = (hd Cycle, 2)"
      using 1 by simp
    have "hd Cy = (hd Cycle, 2)" 
      using Cy_def by simp 
    then show ?thesis using 7 by simp
  qed
qed  


lemma vwalk_arcs_Cy_not_empty: 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "vwalk_arcs Cy \<noteq> []"
proof -
  have "length Cycle > 2" 
    using assms 
    by (simp add: card_verts_impl_length_Cycle)
  then have "length Cycle \<ge> 2"
    by auto
  then have "tl Cycle \<noteq> []"
    using length_geq_2_tt_not_empty by auto
  then have "to_cycle_uhc G (tl Cycle) \<noteq> []"
    by (simp add: c_not_empty_to_cycle_not_empty) 
  then have "length Cy > 1"
    using Cy_def by auto
  then show ?thesis using length_C_vwalk_arcs_not_empty by fast
qed


lemma at_least_to_nodes_vwalk_arcs_awalk_verts: 
  assumes "length C > 1"
  shows "(pre_digraph.awalk_verts G' u (vwalk_arcs C)) = C"
  using head_tail_G'  at_least_to_nodes_vwalk_arcs_awalk_verts assms by fast


lemma distinct_impl_distinct_awalk: 
  assumes "distinct (tl C)"
  shows  "distinct (tl (pre_digraph.awalk_verts G' u (vwalk_arcs C)))"
  using assms proof(induction C)
  case Nil
  then have "vwalk_arcs [] = []"
    by auto
  then have "(pre_digraph.awalk_verts G' u (vwalk_arcs [])) = [u]"
    by (simp add: pre_digraph.awalk_verts.simps(1)) 
  then show ?case by auto
next
  case (Cons a C)
  then have "length (a#C) \<ge> 1" 
    by simp
  then have lac: "length (a#C) = 1 \<or> length (a#C) > 1"
    by simp
  then show ?case proof(cases "length (a#C) = 1")
    case True
    then have "C = []" by auto
    then have "vwalk_arcs [a] = []"
    by auto
  then have "(pre_digraph.awalk_verts G' u (vwalk_arcs [a])) = [u]"
    by (simp add: pre_digraph.awalk_verts.simps(1))
    then show ?thesis 
      by (simp add: \<open>C = []\<close>) 
  next
    case False
    then show ?thesis using at_least_to_nodes_vwalk_arcs_awalk_verts Cons lac 
      by presburger 
  qed
qed


lemma distinct_tl_awalk_cy: 
  shows"distinct (tl (pre_digraph.awalk_verts G' u (vwalk_arcs Cy)))"
  using distinct_impl_distinct_awalk distinct_Cy by simp



lemma cas_to_cycle_uhc: 
  assumes "L = (to_cycle_uhc G C)" "L \<noteq> []"
  shows "pre_digraph.cas G' (hd L) (vwalk_arcs L) (last L)"
  using assms proof(induction C arbitrary: L)
  case Nil
  then show ?case by auto
next
  case (Cons a C)
  have "to_cycle_uhc G (a # C) = [(a, 0), (a,1), (a,2)] @ (to_cycle_uhc G (C))"
    by simp
  then have L_def: "L = [(a, 0), (a,1), (a,2)] @ (to_cycle_uhc G (C))"
    using Cons by blast
  then have "hd L = (a, 0)" by auto
  then have 1: "(vwalk_arcs L) = ((a, 0), (a, 1))# ((a, 1), (a, 2))#  (vwalk_arcs ((a, 2) # to_cycle_uhc G C))"
    using L_def vwalk_arcs.simps by auto
  then show ?case proof(cases "C = []")
    case True
    then have "(to_cycle_uhc G C) = []" 
      by simp
    then have "last L = (a, 2)"
      using L_def by simp 
    then have "vwalk_arcs L = ((a, 0), (a, 1))# ((a, 1), (a, 2)) # []"
      using 1 True by simp
    then have "pre_digraph.cas G' (a, (0::nat)) (((a, 0), (a, 1))# ((a, 1), (a, 2)) # []) (a, 2)"
      using G'_def_2 pre_digraph.cas.simps 
      by (simp add: pre_digraph.cas.simps(1) pre_digraph.cas.simps(2)) 
    then show ?thesis  
      by (simp add: \<open>hd L = (a, 0)\<close> \<open>last L = (a, 2)\<close> \<open>vwalk_arcs L = [((a, 0), a, 1), ((a, 1), a, 2)]\<close>) 
  next
    case False
    then have to_cy_not_empty: "(to_cycle_uhc G C) \<noteq> []" 
      by (simp add: c_not_empty_to_cycle_not_empty) 
    then have 2: "pre_digraph.cas G'  (hd (to_cycle_uhc G (C))) (vwalk_arcs (to_cycle_uhc G (C))) (last (to_cycle_uhc G (C)))"
      using Cons by auto 
    then have "(vwalk_arcs L) = ((a, 0), (a, 1))# ((a, 1), (a, 2))# ((a, 2), hd (to_cycle_uhc G C))# (vwalk_arcs (to_cycle_uhc G C))"
      using 1 to_cy_not_empty by auto
    then show ?thesis using L_def G'_def_2 2 to_cy_not_empty by(simp add: pre_digraph.cas.simps)
  qed
qed



lemma cas_Cy: 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows  "pre_digraph.cas G' (hd Cycle, 2) (vwalk_arcs Cy) (hd Cycle, 2)"
(*Using above lemma only need to do first step*)
proof -
  have "Cycle \<noteq> []" using assms 
    by (simp add: Cycle_not_empty)
  then have tl_Cy_not_empty: "tl Cy \<noteq> []"
    using assms Cy_def vwalk_arcs_Cy_not_empty by auto 
  then have 1: "pre_digraph.cas G' (hd (tl Cy)) (vwalk_arcs (tl Cy)) (last Cy)"
    using cas_to_cycle_uhc Cy_def by simp
  have 2: "hd Cy = (hd Cycle, 2)"
    using Cy_def by simp
  then have 3: "last Cy = (hd Cycle, 2)" 
    using assms hd_last_Cy by auto 
  have "pre_digraph.cas G' (hd Cycle, 2) (vwalk_arcs Cy) (last Cy)"
    using 1 2 G'_def_2 
    by (metis (no_types, lifting) Cy_def tl_Cy_not_empty assms hd_vwalk_arcs_last_p head_tail_G' list.sel(1) list.sel(3) pre_digraph.cas_simp snd_conv vwalk_arcs_Cons vwalk_arcs_Cy_not_empty) 
  then show "pre_digraph.cas G' (hd Cycle, 2) (vwalk_arcs Cy) (hd Cycle, 2)"
    using 3 by simp
qed


lemma hd_to_cycle_uhc: 
  assumes "C \<noteq> []"
  shows "hd (to_cycle_uhc G C) = (hd C, 0)"
  using assms apply(induction C) by(auto)


lemma sublist_Cycle_in_arcs: 
  assumes "card (verts G) > 1" "sublist [a, b] Cycle"
  shows "(a, b) \<in> arcs G"
proof -
  have 1: "(a, b) \<in> set (vwalk_arcs Cycle)"
    using assms sublist_imp_in_arcs by fast 
  have "pre_digraph.cycle G (vwalk_arcs Cycle)"
    using Cycle_def is_hc_def assms 
    by fastforce
  then obtain u where "pre_digraph.awalk G u (vwalk_arcs Cycle) u"
    using pre_digraph.cycle_def by metis
  then have "set (vwalk_arcs Cycle) \<subseteq> arcs G"
    using pre_digraph.awalk_def by metis
  then show ?thesis using 1 
    by auto
qed



lemma hd_hd_tl_Cycle_in_arcs: 
  assumes "tl Cycle \<noteq> []" "card (verts G) > 1"
  shows "(hd Cycle, hd (tl Cycle)) \<in> arcs G"
proof -
  have 1: "(hd Cycle, hd (tl Cycle)) \<in> set (vwalk_arcs Cycle)"
    using assms
    by (metis Nil_tl in_set_member list.collapse member_rec(1) vwalk_arcs_Cons) 
  have "pre_digraph.cycle G (vwalk_arcs Cycle)"
    using Cycle_def is_hc_def assms 
    by fastforce
  then obtain u where "pre_digraph.awalk G u (vwalk_arcs Cycle) u"
    using pre_digraph.cycle_def by metis
  then have "set (vwalk_arcs Cycle) \<subseteq> arcs G"
    using pre_digraph.awalk_def by metis
  then show ?thesis using 1 by auto
qed


lemma hd_Cy_noteq_hd_tl_Cy: 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "hd (tl Cycle) \<noteq> hd Cycle" 
proof (rule ccontr)
  have hl: "hd Cycle = last Cycle"
    using hd_last_Cycle assms by simp
  assume "\<not> hd (tl Cycle) \<noteq> hd Cycle" 
  then have "hd (tl Cycle) = hd Cycle" 
    by simp
  then have 1: "hd (tl Cycle) = last Cycle" 
    using hl by simp
  have "tl Cycle \<noteq> []" 
    using card_verts_impl_length_Cycle assms 
    using length_geq_2_tt_not_empty by force 
  then have "tl Cycle = [hd Cycle]"
    using distinct_tail_cycle 1 
    by (metis \<open>hd (tl Cycle) = hd Cycle\<close> append.right_neutral last_tl list.set_sel(1) sublist_set_last_ls1_2)  
  then have cy_def: "Cycle= [hd Cycle, hd Cycle]"
    using distinct_tail_cycle hl 
    by (metis Nil_tl list.discI list.exhaust_sel)
  have "length [hd Cycle, hd Cycle] = 2"
    by simp
  then have "length Cycle = 2"
    using cy_def by(auto)
  then show False using assms 
    using card_verts_impl_length_Cycle by auto 
qed


lemma uv_in_G_in_G': 
  assumes "u\<noteq> v"
    "(u, v) \<in> arcs G"
  shows "((u, 2), (v, 0)) \<in> arcs G'"
  using assms G'_def_2 
  using wf_digraph_G(2) by auto 


lemma hd_Cy_hd_tl_in_arcs_G': 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1" "sublist [a, b] Cy" "a = hd Cy"
  shows "(a, b) \<in> arcs G'"
proof -
  have tail_head_G: 
    "tail G = fst" "head G = snd"
    using wf_digraph_G assms by simp+
  have a_def: "a = (hd Cycle, 2)"
    using assms Cy_def by simp
  have Cycle_not_empty: "Cycle \<noteq> []" 
    using assms 
    by (simp add: Cycle_not_empty) 
  have tl_Cycle_not_empty: "tl Cycle \<noteq> []"
    using assms Cy_def vwalk_arcs_Cy_not_empty by auto 
  have "distinct (tl Cy)" "a = last Cy"
    using assms hd_last_Cy
     apply (simp add: distinct_Cy hd_last_Cy) 
    using assms  hd_last_Cy by blast 
  then have "b = hd (tl Cy)" 
    using sublist_hd_tl_equal_b_hd_tl assms
    by fast
  then have b_def: "b = (hd (tl Cycle), 0)"
    using Cy_def hd_to_cycle_uhc tl_Cycle_not_empty by(auto)
  then have "(hd Cycle, hd (tl Cycle)) \<in> arcs G" 
    "head G (hd Cycle, hd (tl Cycle)) = (hd (tl Cycle))"
    "tail G (hd Cycle, hd (tl Cycle)) = (hd (Cycle))"
    using assms hd_hd_tl_Cycle_in_arcs tl_Cycle_not_empty apply blast using assms 
    using tail_head_G by auto 
  then have "((hd Cycle, 2), (hd (tl Cycle), 0)) \<in> arcs G'"
    using G'_def_2 tail_head_G hd_Cy_noteq_hd_tl_Cy uv_in_G_in_G' 
    using in_hc(2) by auto
  then show ?thesis using a_def b_def by simp
qed 


lemma in_Cycle_in_verts: 
  assumes "a \<in> set Cycle"
  shows "a \<in> verts G"
  using Cycle_def is_hc_def assms by fast


lemma helper_arcs_first_list: 
  assumes "sublist [(a, i), (b, j)] [(c, 0), (c, (1::nat)), (c, 2)]"
  shows "(a = b \<and> a \<in> set (c#C) \<and> b \<in> set (c#C) \<and> ((i = 0 \<and> j = 1) \<or> (i = 1 \<and> j = 2)))"
proof -
  have distinct: "distinct [(c, (0::nat)), (c, 1), (c, 2)]"
    by(auto)
  have in_set: "(a, i) \<in> set [(c, 0), (c, 1), (c, 2)]" "(b, j) \<in> set [(c, 0), (c, 1), (c, 2)]"
    using assms 
    by (meson in_sublist_impl_in_list list.set_intros)+
  then have "a = c" "b = c" 
    by auto
  then have 1: "a = b" "a \<in> set (c#C)" "b \<in> set (c#C)"
    by auto
  have "((i = 0 \<and> j = 1) \<or> (i = 1 \<and> j = 2))"
  proof(cases "i = 0")
    case True
    then have "[(c, (0::nat)), (c, 1), (c, 2)] = (a, i) #  [(c, 1), (c, 2)]"
      by (simp add: \<open>a = c\<close>) 
    then have "(b, j) = (c, 1)" 
      using assms sublist_imp_in_arcs by fastforce 
    then show ?thesis 
      using True by blast 
  next
    case False
    then have "i = 1 \<or> i = 2"
      using in_set by auto 
    then show ?thesis proof
      assume "i = 1" 
      then have "(b, j) = (c, 2)" 
        using \<open>b = c\<close> assms sublist_imp_in_arcs by fastforce 
      then show ?thesis 
        using \<open>i = 1\<close> by auto
    next
      assume "i = 2" 
      then have "False" using assms 
        using sublist_imp_in_arcs by fastforce 
      then show ?thesis by simp
    qed
  qed
  then show ?thesis using 1 by auto
qed


lemma to_cycle_uhc_sublist_sublist_of_C: 
  assumes "L = to_cycle_uhc G C" "sublist [(a, i), (b, j)] L" "distinct L"
  shows "(sublist [a, b] C \<and> i = 2 \<and> j = 0) \<or> (a = b \<and> a \<in> set C \<and> b \<in> set C \<and> ((i = 0 \<and> j = 1) \<or> (i = 1 \<and> j = 2)))"
  using assms proof(induction C arbitrary: L)
  case Nil
  then have "L \<noteq> []"
    by (simp add: sublist_def) 
  then show ?case using Nil by simp
next
  case (Cons c C)
  then have "L = [(c, 0), (c, 1), (c, 2)] @ to_cycle_uhc G C" 
    by simp
  then have 1: "sublist [(a, i), (b, j)] ([(c, 0), (c, 1), (c, 2)] @ to_cycle_uhc G C)"
      "distinct ([(c, 0), (c, 1), (c, 2)] @ to_cycle_uhc G C)" 
      "[(c, 0), (c, 1), (c, 2)] \<noteq> []"
    using Cons by auto
  then have "sublist [(a, i), (b, j)] [(c, 0), (c, 1), (c, 2)] \<or>
    sublist [(a, i), (b, j)] (to_cycle_uhc G C) \<or>
    (a, i) = (c, 2) \<and> (b, j) = hd (to_cycle_uhc G C)"
    using sublist_append_using_or 
    by fastforce 
  then show ?case proof
    assume "sublist [(a, i), (b, j)] [(c, 0), (c, 1), (c, 2)]"
    then have "a = b \<and> a \<in> set (c # C) \<and> b \<in> set (c # C) \<and> (i = 0 \<and> j = 1 \<or> i = 1 \<and> j = 2)"
      using helper_arcs_first_list by metis
    then show ?thesis using helper_arcs_first_list 1 by blast
  next 
    assume "sublist [(a, i), (b, j)] (to_cycle_uhc G C) \<or> (a, i) = (c, 2) \<and> (b, j) = hd (to_cycle_uhc G C)"
    then show ?thesis proof
      assume "sublist [(a, i), (b, j)] (to_cycle_uhc G C)"
      then have "(sublist [a, b] C \<and> i = 2 \<and> j = 0) \<or> (a = b \<and> a \<in> set C \<and> b \<in> set C \<and> ((i = 0 \<and> j = 1) \<or> (i = 1 \<and> j = 2)))"
        using Cons by simp
      then show ?thesis 
        by (meson list.set_intros(2) sublist_cons) 
    next
      assume a1: "(a, i) = (c, 2) \<and> (b, j) = hd (to_cycle_uhc G C)"
      then have "(to_cycle_uhc G C) \<noteq> []" 
        using Cons 
        by (metis \<open>L = [(c, 0), (c, 1), (c, 2)] @ to_cycle_uhc G C\<close> append.right_neutral helper_arcs_first_list one_eq_numeral_iff semiring_norm(85) zero_neq_numeral) 
      then have C_not_empty: "C \<noteq> []"
        by auto
      then have b_def: "(b, j) = (hd C, 0)"
        using hd_to_cycle_uhc a1 by simp
      then have "[]@[a, b]@(tl C) = c#C" 
        using a1 C_not_empty 
        by simp
      then have "sublist [a, b] (c # C)" 
        using sublist_def by blast 
      then show ?thesis using a1 b_def by force
    qed
  qed
qed 


lemma sublist_disitnct_not_eq: 
  assumes "sublist [a, b] C" "distinct C"
  shows "a \<noteq> b"
  using assms proof(induction C)
  case Nil
  then show ?case 
    by (simp add: sublist_def) 
next
  case (Cons c C)
  then show ?case 
    by (meson sublist_not_cyclic_for_distinct) 
qed


lemma sublist_ab_a_noteq_b: 
  assumes "sublist [a, b] Cycle" "1 < card (verts G)" "arcs G \<noteq> {}"
  shows "a \<noteq> b" 
proof(cases "a = hd Cycle")
  case True
  then have "distinct (tl Cycle)" "a = last Cycle"
    using distinct_tail_cycle hd_last_Cycle assms
    by simp+
  then have "b = hd (tl Cycle)" 
    using sublist_hd_tl_equal_b_hd_tl assms
    by (simp add: sublist_hd_tl_equal_b_hd_tl local.hd_last_Cycle) 
  then show ?thesis 
    using True assms(3) hd_Cy_noteq_hd_tl_Cy in_hc(2) by auto 
next
  case False
  then have "sublist [a, b] (tl Cycle)"
    using assms 
    by (metis hd_Cons_tl list.sel(2) sublist_cons_impl_sublist) 
  then show ?thesis using distinct_tail_cycle sublist_disitnct_not_eq by fastforce
qed



lemma Cy_arcs_in_arcs_G': 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "set (vwalk_arcs Cy) \<subseteq> arcs G'"
proof   
  have d_tl_C: "distinct (tl Cycle)"
    using assms 
    by (simp add: distinct_tail_cycle) 
  then have dL: "distinct (to_cycle_uhc G (tl Cycle))" 
    using distinct_C_distinct_uhc_cycle
    by simp
  have tail_head_G: 
    "tail G = fst" "head G = snd"
    using wf_digraph_G assms by simp+
  fix x assume x_def: "x \<in> set (vwalk_arcs Cy)"
  then have "\<exists>a b. x = (a, b)"
    by (meson prod_cases3)   
  then obtain a b where ab_def: "x = (a, b)"
    by auto
  then have sublist: "sublist [a, b] Cy"
    using x_def sublist_def sublist_for_edges 
    by fast
  then have "a = hd Cy \<or> sublist [a, b] (tl Cy)"
    by (metis ab_def distinct.simps(2) distinct_singleton hd_Cons_tl in_set_vwalk_arcsE sublist_cons_impl_sublist x_def) 

  then show "x \<in> arcs G'"
  proof 
    assume "a = hd Cy"
    then show ?thesis
      using hd_Cy_hd_tl_in_arcs_G' assms ab_def sublist by(auto)
  next
    assume "sublist [a, b] (tl Cy)" 
    then have s_tcu: "sublist [a, b] (to_cycle_uhc G (tl Cycle))"
      using Cy_def by simp
    obtain a1 a2 b1 b2 where ab_def_2: "a = (a1, a2)" "b = (b1, b2)"
      by fastforce
    then have "(sublist [a1, b1] (tl Cycle) \<and> a2 = 2 \<and> b2 = 0) 
      \<or> (a1 = b1 \<and>a1 \<in> set (tl Cycle) \<and> b1 \<in> set (tl Cycle) \<and> ((a2 = 0 \<and> b2 = 1) \<or> (a2 = 1 \<and> b2 = 2)))"
      using to_cycle_uhc_sublist_sublist_of_C s_tcu ab_def_2 dL by simp 
    then show ?thesis proof 
      assume a1: "(sublist [a1, b1] (tl Cycle) \<and> a2 = 2 \<and> b2 = 0)"
      then have "sublist [a1, b1] Cycle" 
        by (metis hd_Cons_tl list.sel(2) sublist_cons) 
      then have "(a1, b1) \<in> arcs G" "a1 \<noteq> b1"
        using sublist_Cycle_in_arcs assms sublist_ab_a_noteq_b by auto
      then have "((a1, 2), (b1, 0)) \<in> arcs G'"
        using G'_def_2 tail_head_G sublist_ab_a_noteq_b by force 
      then have "((a1, a2), (b1, b2)) \<in> arcs G'"
        using a1 by auto 
      then show ?thesis using ab_def_2 ab_def by auto
    next
      assume a1: "(a1 = b1 \<and> a1 \<in> set (tl Cycle) \<and> b1 \<in> set (tl Cycle) \<and> ((a2 = 0 \<and> b2 = 1) \<or> (a2 = 1 \<and> b2 = 2)))"
      then have a_eq_b: "a1 = b1" "((a2 = 0 \<and> b2 = 1) \<or> (a2 = 1 \<and> b2 = 2))" "a1 \<in> verts G" 
        using in_Cycle_in_verts by (auto simp add: a1 in_Cycle_in_verts list_set_tl) 
      then have "((a1, 0), (a1, 1)) \<in> arcs G'"  "((a1, 1), (a1, 2)) \<in> arcs G'" 
        using G'_def_2 
        by simp+
      then show ?thesis using a_eq_b ab_def ab_def_2 by auto 
    qed
  qed
qed



lemma awalk_G'_Cy: 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "pre_digraph.awalk G' (hd Cycle, 2) (vwalk_arcs Cy) (hd Cycle, 2)"
proof -
  have 1: "(hd Cycle, 2) \<in> verts G'"
    using assms Cy_def set_Cy_subset_G' by auto  
  have 2: "set (vwalk_arcs Cy) \<subseteq> arcs G'"
    using assms Cy_arcs_in_arcs_G' by simp 
  have 3: "pre_digraph.cas G' (hd Cycle, 2) (vwalk_arcs Cy) (hd Cycle, 2)"
    using assms cas_Cy by blast
  then show ?thesis using pre_digraph.awalk_def 1 2 3 by fast 
qed



lemma pre_digraph_cycle_Cy_G':
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "pre_digraph.cycle G' (vwalk_arcs Cy)"
  unfolding pre_digraph.cycle_def 
  using assms vwalk_arcs_Cy_not_empty distinct_tl_awalk_cy awalk_G'_Cy by blast


lemma card_verts_length_Cy: 
  assumes "card (verts G) > 1"
  shows "length Cy \<ge> 2" 
proof -
  have "card (verts G') > 1"
    using card_verts_G'_2 assms by simp 
  then have "length Cy > 1" 
    using Cy_def 
    by (metis assms c_not_empty_to_cycle_not_empty card_verts_impl_length_Cycle impossible_Cons le_antisym length_geq_2_tt_not_empty length_greater_0_conv less_one less_or_eq_imp_le linorder_neqE_nat list.sel(3) nat_less_le no_arcs_impl_at_most_one_vertex not_gr0) 
  then show ?thesis by auto
qed


lemma vwalk_cycle_Cy_G': 
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "vwalk_cycle G' Cy"
proof -
  have 1: "length Cy \<ge> 2" 
    using assms 
    by (simp add: card_verts_length_Cy) 
  have "pre_digraph.cycle G' (vwalk_arcs Cy)"
    using assms pre_digraph_cycle_Cy_G' by auto 
  then show ?thesis 
    using 1 cycle_implies_vwalk_cycle head_tail_G' wf_digraph_G' by auto
qed


lemma is_uhc_Cy_G':
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "is_uhc G' Cy"
  unfolding is_uhc_def 
  using assms distinct_Cy set_Cy_subset_G' all_verts_G'_in_Cy vwalk_cycle_Cy_G' 
    cycle_implies_vwalk_cycle  
  by presburger


lemma arcsG_non_empty_exists_cycleG':
  assumes "arcs G \<noteq> {}" "card (verts G) > 1"
  shows "\<exists>c.  is_uhc G' c"
  using assms is_uhc_Cy_G' by auto


lemma in_uhc: "hc_to_uhc G \<in> uhc"
proof -
  have 1: "head G' = snd" "tail G' = fst"
    using head_tail_G' by auto
  have 2: "symmetric G'"
    using symmetric_G' by auto
  have 3: "wf_digraph G'" 
    using wf_digraph_G' by auto
  have 4: "\<exists>c.  is_uhc G' c"
  proof(cases "arcs G = {}")
    case True
    then show ?thesis 
      using arcsG_empty_exists_cycleG' 
      by auto
  next
    case False
    then have "card (verts G) > 1"
      using in_hc by auto 
    then show ?thesis 
      using arcsG_non_empty_exists_cycleG' False by blast 
  qed
  show ?thesis 
    using G'_def 1 2 3 4 uhc_def 
    using finite_verts_G' by blast
qed
  
end



end