# Class: NumericalSemigroup
# 
# Author: Christopher O'Neill
# 
# A python class to ease the interface between Sage and the GAP package "numericalsgps".  
# All types returned are true Sage types, not just wrappers around GAP types that gap() returns
# Autocomplete is supported, typing McNuggets.<TAB> will give a list of available functions
# 
# Feel free to copy and make changes, but please leave the original (Dropbox) version unedited.  
# More functionality will be added, and feature requests are welcome, just email author
# 
##################
# 
# Usage: 
# 
# load('/PATH_TO_FILE/NumericalSemigroup.sage')
# 
# McNuggets = NumericalSemigroup([6,9,20])
# 
# print(McNuggets.frob)
# print(McNuggets.LengthSet(400))
# print(McNuggets.DeltaSet(400))
# print(McNuggets.OmegaPrimality(400))
# print(McNuggets.CatenaryDegree(400))
# 
##################




# TODO: 
# non-primitive monoids
# allow Quasipolynomial to have gaps


# TODO:
# @memoized for archiving
# gap lib for faster conversion
# function_factory for gap functions
# true python rather than Sage
# bundle as Sage addon together with GAP package



print(gap('LoadPackage("numericalsgps");'))

if gap('NumSgpsUseSingular();'):
	print("Successfully loaded Singular")

# gap('''
# EqualCatenaryDegreeOfElementInNumericalSemigroup:=function(n,s)
# 	return EqualCatenaryDegreeOfSetOfFactorizations(FactorizationsElementWRTNumericalSemigroup(n,s));
# end;
# ''')

# gap('''
# AdjacentCatenaryDegreeOfElementInNumericalSemigroup:=function(n,s)
# 	return AdjacentCatenaryDegreeOfSetOfFactorizations(FactorizationsElementWRTNumericalSemigroup(n,s));
# end;
# ''')

# gap('''
# EqualAndAdjacentCatenaryDegreesOfElementInNumericalSemigroup:=function(n,s)
# 	local f;
# 	f:=FactorizationsElementWRTNumericalSemigroup(n,s);
# 	return [EqualCatenaryDegreeOfSetOfFactorizations(f),AdjacentCatenaryDegreeOfSetOfFactorizations(f)];
# end;
# ''')




def CreateNumericalSemigroup(gens,name=""):
	genstr = ','.join([str(i) for i in gens])
	if name == "":
		return gap('NumericalSemigroupByGenerators(' + genstr + ');')
	else:
		gap.eval(name + ' := NumericalSemigroupByGenerators(' + genstr + ');')
		return gap(name + ';')



def FactorizationsInNN(gens, m):
	#if n in gens:
	#	return [[n]]
	
	if len(gens) == 1:
		return [] if m % gens[0] != 0 else [[m/gens[0]]]
	
	facts = []
	lessgens = gens[:-1]
	for i in range(int(m/gens[-1])+1):
		facts = facts + [fact + [i] for fact in FactorizationsInNN(lessgens, m-(i*gens[-1]))]
	
	return facts
	
	
	# allfacts = {0:[[0 for g in gens]]}
	
	# for g in gens:
	# 	allfacts[g].append([g])
	# 	for n in gens:
	# 		if i >= n:
	# 			break
			
	# 		if not(n-i in gens):
	# 			continue
			
	# 		subfacts = allfacts[n-i]
	# 		for fact in subfacts:
	# 			if fact[-1] <= i:
	# 				allfacts[n].append(fact + [i])
	
	'''
	# heights check
	facts = []
	
	for l in allfacts[m]:
		lower = sum([S.FirstIrreducibleAt(i)-1 for i in l if S.FirstIrreducibleAt(i) < oo])
		upper = sum([S.HeightOfRow(i)-1 for i in l if S.HeightOfRow(i) < oo and S.FirstIrreducibleAt(i) < oo])
		
		if h - len(l) >= lower and h - len(l) <= upper:
			facts.append(l)
	'''
	
	# return facts


def LengthsInNN(gamma,gens,m):
	return [len(l) for l in FactorizationsInNN(gamma,gens,m)]



def TableFromValueMap(valuemap, width = 10):
	if type(valuemap) == type([]):
		values = range(len(valuemap))
	
	nmin = min(valuemap.keys())
	nmax = max(valuemap.keys())
	
	nmin = nmin - (nmin % width)
	nmax = nmax + ((width - nmax) % width)
	
	tableret = []
	
	for i in [nmin .. nmax]:
		if i in valuemap.keys():
			tableret = tableret + [[i, valuemap[i],'']]
		else:
			tableret = tableret + [['','','']]
	
	tableret = [sum([tableret[j*width + i] for i in range(width)],[]) for j in range(int((nmax - nmin)/width))]
	#table = [[k for j in range(splits) for k in [[k for j in range(splits) for k in table[splits*i + j]][:-1] for i in range(int(nmax/splits))]
	
	return table(tableret)




# Currently supports list and int types
def ConvertGapToSage(var):
	# attempt list conversion
	try:
		ret = [ConvertGapToSage(j) for j in var]
		
		return ret
	except:
		pass
	
	# attempt bool conversion
	if var == gap('true;') or var == gap('false;'):
		ret = bool(var)
		
		return ret
	
	# attempt int conversion
	try:
		ret = Rational(var)
		
		if ret.denominator() == 1:
			ret = Integer(ret)
		
		return ret
	except:
		pass
	
	return 0


@parallel(ncpus=4)#sage.parallel.ncpus.ncpus())
def Internal_ParallelCatenaryDegrees(gens, n):
	return ConvertGapToSage(gap('CatenaryDegreeOfSetOfFactorizations(FactorizationsIntegerWRTList(%d,%s));'%(n,str(gens))))

@parallel(ncpus=4)#sage.parallel.ncpus.ncpus())
def Internal_ParallelEqualCatenaryDegrees(gens, n):
	return ConvertGapToSage(gap('EqualCatenaryDegreeOfSetOfFactorizations(FactorizationsIntegerWRTList(%d,%s));'%(n,str(gens))))

@parallel(ncpus=4)#sage.parallel.ncpus.ncpus())
def Internal_ParallelAdjacentCatenaryDegrees(gens, n):
	return ConvertGapToSage(gap('AdjacentCatenaryDegreeOfSetOfFactorizations(FactorizationsIntegerWRTList(%d,%s));'%(n,str(gens))))



def LLLReducedBasis(l):
	return ConvertGapToSage(gap('LLLReducedBasis(' + str(l) + ').basis;'))


def DeltaListFromList(l):
	return [l[i+1] - l[i] for i in range(len(l)-1)]

def DeltaSetFromLengthSet(lenset):
	return Set(DeltaListFromList(list(lenset)))


class Quasipolynomial:
	
	def __init__(self, coeffs):
		self.coeffs = coeffs
		self.degree = len(coeffs)-1
		self.gens = None
		
		self.periods = None
		self.period = len(coeffs[0])
	
	def __call__(self, val):
		return sum([self.coeffs[i][val % self.period]*(val^i) for i in [0..self.degree]])
	
	def FrobeniusNumbers(self, kmax, usezeros = False):
		if self.gens == None:
			return {1:0}
		
		m = min(self.gens)
		vals = [0 for i in range(m)]
		exceedcount = 0
		
		ret = [0 for i in [0..kmax]] if usezeros else {1:0}
		i = 0
		while exceedcount < m:
			i = i + 1
			
			if vals[i % m] > kmax:
				continue
			
			vals[i % m] = self(i)
			if vals[i % m] <= kmax:
				ret[vals[i % m]] = i
			else:
				exceedcount = exceedcount + 1
		
		return ret
	
	def DissonancePoint(self, vals):
		return max([0] + [i for i in range(len(vals)) if self(i) != vals[i]])
	
	@staticmethod
	def FromCoefficients(vals, per, d, leadingcoeff = None):
		l = len(vals)
		if leadingcoeff != None:
			d = d - 1
			if type(leadingcoeff) != type([4]):
				leadingcoeff = [leadingcoeff]*per
		
		if l < per*(d+1):
			print("Not enough values provided!")
			return
		
		ret = [[0 for j in [0..per-1]] for i in [0..d]]
		for i in [0..per-1]:
			A = Matrix([[(l - 1 - (k2*per + i))^k1 for k1 in [0..d]] for k2 in [0..d]])
			
			b = vector([vals[l - 1 - (k*per + i)] for k in [0..d]])
			if leadingcoeff != None:
				b = b - vector([leadingcoeff[(l - 1 - i) % per]*((l - 1 - (k2*per + i))^(d+1)) for k2 in [0..d]])
			
			sol = A.solve_right(b)
			#sol = octave.solve_linear_system(A,b)
			
			for j in [0..d]:
				ret[j][(l - 1 - i) % per] = sol[j]
		
		if leadingcoeff != None:
			ret = ret + [leadingcoeff]
		
		return Quasipolynomial(ret)
	
	@staticmethod
	def FromGenerators(gens):
		maxval = lcm(gens)*(len(gens)-1)
		lcoef = 1/(factorial(len(gens)-1)*prod(gens))
		
		factcountlist = [0 for i in range(maxval)]
		factcountlist[0] = 1
		
		for g in gens:
			i = g
			while i < maxval:
				factcountlist[i] = factcountlist[i] + factcountlist[i-g]
				i = i + 1
		
		ret = Quasipolynomial.FromCoefficients(factcountlist, lcm(gens), len(gens)-1, lcoef)
		ret.gens = gens
		
		return ret

Quasipolynomial.KFrobeniusNumbers = Quasipolynomial.FrobeniusNumbers



class NumericalSemigroup:
	
	def __init__(self, gens = None):
		#self.gapname = 'x'.join([str(i) for i in gens]) + 'xxSageInternal'
		if gens != None:
			self.__InitWithGapSemigroup(CreateNumericalSemigroup(gens))
		
	
	def __InitWithGapSemigroup(self, semigroup):
		self.semigroup = semigroup
		self.gens = [int(gen) for gen in self.semigroup.MinimalGeneratingSystemOfNumericalSemigroup()]
		#self.FrobeniusNumber() = int(self.semigroup.FrobeniusNumberOfNumericalSemigroup())
		#self.gaps = Set([int(i) for i in self.semigroup.GapsOfNumericalSemigroup()])
		
		self.__InitWithDefaults()
		
		return self
	
	def __InitWithDefaults(self):
		self.__aperysets = {}
		#self.AperySet(self.gens[0])
		self.__isirreducible = [None]
		self.__iscompleteintersection = [None]
		self.__isarf = [None]
		self.__gluings = [None]
		self.__gaps = [None]
		self.__frob = [None]
		self.__type = [None]
		self.__bettielements = [None]
		self.__higherbettinumbers = None
		self.__psuedofrobs = [None]
		self.__minimalpresentation = [None]
		self.__oversemigroups = [None]
		
		self.__factorizations = {}
		self.__factorizationquasi = None
		self.__lengthsets = {}
		self.__lensetquasi = None
		self.__deltaset = [None]
		self.__deltasets = {}
		self.__deltasetperiodicitybound = [None]
		self.__deltasetperiodicitystart = [None]
		self.__elasticity = [None]
		self.__elasticities = {}
		self.__catenarydegree = [None]
		self.__catenaries = {}
		self.__equalcatenarydegree = [None]
		self.__equalcatenaries = {}
		self.__adjacentcatenarydegree = [None]
		self.__adjacentcatenaries = {}
		self.__monotonecatenarydegree = [None]
		self.__monotonecatenaries = {}
		self.__tamedegree = [None]
		self.__tamedegrees = {}
		
		self.__weight = [1]*len(self.gens)
		self.__weightedlengthsets = {}
		self.__weightedmaxlengths = {}
		
		self.__omegas = {}
		self.__bullets = {}
		self.__maxbullets = {}
	
	def SaveToString(self):
		return str({i:self.__dict__[i] for i in self.__dict__.keys() if i != 'semigroup' and self.__dict__[i] != {} and self.__dict__[i] != [None]})
		#return str({i:j for (i,j) in vars(self) if i != 'semigroup'})
	
	@staticmethod
	def Load(semistr):
		ret = NumericalSemigroup()
		ret.__InitWithDefaults()
		
		d = eval(semistr)
		for a in d.keys():
			ret.__dict__[a] = d[a]
		
		ret.semigroup = CreateNumericalSemigroup(ret.gens)
		return ret
	
	def Contains(self, n):
		return int(n) >= self.AperySet(self.gens[0])[int(n) % self.gens[0]]
	
	def IsSubsemigroupOf(self, S):
		m = min(self.gens)
		return m in S and all([a1 >= a2 for (a1, a2) in zip(self.AperySet(m), S.AperySet(m))])
	
	def IsSymmetric(self):
		return self.FrobeniusNumber() % 2 == 1 and len([i for i in [1..self.FrobeniusNumber()] if i not in self]) == (self.FrobeniusNumber() + 1)/2
	
	def __GenericGapCallGlobal(self, should_use_store_loc, store_loc, gapfuncname, insert_inputs = True):
		if should_use_store_loc and store_loc[0] != None:
			return store_loc[0]
		
		if insert_inputs:
			ret = ConvertGapToSage(gap(gapfuncname + '(' + self.semigroup.name() + ')'))
		else:
			ret = ConvertGapToSage(gap(gapfuncname))
		
		if should_use_store_loc:
			store_loc[0] = ret
		
		return ret
	
	def __GenericGapCall(self, n, should_use_store_loc, store_loc, gapfuncname, semigroup_first = False, insert_inputs = True):
		if should_use_store_loc and (n in store_loc.keys()):
			return store_loc[n]
		
		if insert_inputs:
			if semigroup_first:
				ret = ConvertGapToSage(gap(gapfuncname + '(%s,%d)'%(self.semigroup.name(),n)))
			else:
				ret = ConvertGapToSage(gap(gapfuncname + '(%d,%s)'%(n,self.semigroup.name())))
		else:
			ret = ConvertGapToSage(gap(gapfuncname))
		
		if should_use_store_loc:
			store_loc[n] = ret
		
		return ret
	
	def __IsCallSaved(self, store_loc):
		return store_loc[0] == None
	
	def __IsGlobalCallSaved(self, n, store_loc):
		return n in store_loc
	
	def IsIrreducible(self, should_use_store_loc = True):
		return True if self.__GenericGapCallGlobal(should_use_store_loc, self.__isirreducible, 'IsIrreducibleNumericalSemigroup') is True else False
	
	def IsCompleteIntersection(self, should_use_store_loc = True):
		return True if self.__GenericGapCallGlobal(should_use_store_loc, self.__iscompleteintersection, 'IsACompleteIntersectionNumericalSemigroup') is True else False
	
	def IsArf(self, should_use_store_loc = True):
		return True if self.__GenericGapCallGlobal(should_use_store_loc, self.__isarf, 'IsArfNumericalSemigroup') is True else False
	
	def Gluings(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__gluings, 'AsGluingOfNumericalSemigroups')
	
	def KunzCoordinates(self, m = None):
		if m == None:
			m = min(self.gens)
		
		ap = self.AperySet(m)
		coords = [(ap[i] - i)/m for i in range(1,len(ap))]
		
		return coords
	
	#def Glue(self, S2, a1, a2):
	#	return NumericalSemigroup([a1*g for g in self.gens] + [a2*g for g in S2.gens])
	
	def BettiElements(self, should_use_store_loc = True):
		if self.__minimalpresentation != [None]:
			self.__bettielements = list(sorted([sum([a*b for (a,b) in zip(f1,self.gens)]) for [f1,f2] in self.__minimalpresentation[0]]))
			return self.__bettielements
		
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__bettielements, 'BettiElementsOfNumericalSemigroup')
	
	def MinimalPresentation(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__minimalpresentation, 'MinimalPresentationOfNumericalSemigroup')
	
	def AperySet(self, n, should_use_store_loc = True):
		return self.__GenericGapCall(n, should_use_store_loc, self.__aperysets, 'AperyListOfNumericalSemigroupWRTElement', semigroup_first = True)
	
	def Gaps(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__gaps, 'GapsOfNumericalSemigroup')
	
	def FrobeniusNumber(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__frob, 'FrobeniusNumberOfNumericalSemigroup')
		# return [[int(j) for j in l] for l in gap('FactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name()))]
	
	def Type(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__type, 'TypeOfNumericalSemigroup')
		# return [[int(j) for j in l] for l in gap('FactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name()))]
	
	def PseudoFrobeniusNumbers(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__psuedofrobs, 'PseudoFrobeniusOfNumericalSemigroup')
		# return [[int(j) for j in l] for l in gap('FactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name()))]
	
	def Oversemigroups(self):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('OverSemigroupsNumericalSemigroup(' + self.semigroup.name() + ')')]
	
	def Factorizations(self, n, dumb = False, should_use_store_loc = True):
		if not dumb:
			return self.__GenericGapCall(n, should_use_store_loc, self.__factorizations, 'FactorizationsElementWRTNumericalSemigroup')
		
		return self.DumbFactorizations(n)
		# return [[int(j) for j in l] for l in gap('FactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name()))]
	
	def DumbFactorizations(self, n):
		if n in self.__factorizations:
			return self.__factorizations[n]
		
		self.__factorizations[n] = FactorizationsInNN(self.gens,n)
		return self.__factorizations[n]
	
	def FactorizationsUpToElement(self, nmax):
		self.__factorizations[0] = [tuple([0 for g in self.gens])]
		
		for n in [1 .. nmax]:
			if n in self.__factorizations:
				continue
			
			self.__factorizations[n] = []
			
			for i in range(len(self.gens)):
				if n - self.gens[i] < 0:
					continue
				
				for f in self.__factorizations[n - self.gens[i]]:
					toadd = list(f)
					toadd[i] = toadd[i] + 1
					self.__factorizations[n].append(tuple(toadd))
			
			self.__factorizations[n] = list(Set(self.__factorizations[n]))
	
	def FactorizationsForElasticities(self):
		self.FactorizationsUpToElement(self.gens[-1]*self.gens[-2] + self.gens[-1])
	
	def LengthSetsForElasticities(self):
		self.LengthSetsUpToElement(self.gens[-1]*self.gens[-2] + self.gens[-1])
	
	def FactorizationGraph(self, n, factorizations = None, relations = None, deltamax = oo):
		if factorizations == None:
			factorizations = self.Factorizations(n)
		factorizations = [tuple(f) for f in factorizations]
		G = Graph()
		G.add_vertices(factorizations)
		for v1 in factorizations:
			for v2 in factorizations:
				if relations == None: 
					if v1 != v2 and any([(v1[i] > 0 and v2[i] > 0) for i in range(len(v1))]) and abs(sum(v1) - sum(v2)) <= deltamax:
						G.add_edge([v1, v2])
				else:
					if [v1,v2] in relations or [v2,v1] in relations:
						G.add_edge([v1, v2])
		return G
	
	def PlotFactorizationGraph(self, n, factorizations = None, relations = None, deltamax = oo):
		return self.FactorizationGraph(n, factorizations, relations, deltamax).plot(layout="circular", vertex_size=2000)
	
	def PresentationGraph(self, n, factorizations = None, relations = None):
		if factorizations is None:
			factorizations = self.Factorizations(n)
		if relations is None:
			relations = self.MinimalPresentation()
		factorizations = [tuple(f) for f in factorizations]
		relations = [tuple([i-j for (i,j) in zip(r[0],r[1])]) for r in relations] + [tuple([j-i for (i,j) in zip(r[0],r[1])]) for r in relations]
		
		G = Graph()
		G.add_vertices(factorizations)
		for v1 in factorizations:
			for v2 in factorizations:
				if v1 != v2 and tuple([i-j for (i,j) in zip(v1,v2)]) in relations:
					G.add_edge([v1, v2])
		return G
	
	def PlotPresentationGraph(self, n, factorizations = None, relations = None):
		return self.PresentationGraph(n, factorizations, relations).plot(layout="circular", vertex_size=2000)
	
	def SquarefreeDivisorComplex(self, n):
		def f(G):
			return n - sum(G) in self
		
		return SimplicialComplex(from_characteristic_function=(f, self.gens))
	
	def HigherBettiNumbers(self, with_multiplicity = True):
		if self.__higherbettinumbers == None:
			last = self.FrobeniusNumber() + sum(self.gens)
			complexes = {n:self.SquarefreeDivisorComplex(n) for n in [1 .. last]}
			homologies = {n:complexes[n].homology() for n in complexes}
			self.__higherbettinumbers = {i+1:sum([[n]*len(homologies[n][i].gens()) for n in homologies if i in homologies[n]], []) for i in [0 .. len(self.gens)-1]}
		
		if with_multiplicity:
			return self.__higherbettinumbers
		else:
			return {i:list(set(self.__higherbettinumbers[i])) for i in self.__higherbettinumbers}
	
	def FactorizationQuasipolynomial(self):
		if self.__factorizationquasi == None:
			maxval = lcm(self.gens)*(len(self.gens)-1)
			lcoef = 1/(factorial(len(self.gens)-1)*prod(self.gens))
			snm = self.semigroup.name()
			
			gcomm = 'List([1..%d], function(i) if not(i in %s) then return 0; else return Length(FactorizationsElementWRTNumericalSemigroup(i,%s)); fi; end)'
			factcountlist = [1] + ConvertGapToSage(gap(gcomm % (maxval,snm,snm)))
			
			self.__factorizationquasi = Quasipolynomial.FromCoefficients(factcountlist, lcm(self.gens), len(self.gens)-1, lcoef)
		
		return self.__factorizationquasi
	
	def FrobeniusNumbers(self,maxk):
		quasi = self.FactorizationQuasipolynomial()
		maxval = self.FrobeniusNumber() + maxk*max(self.gens)
		
		ret = {i:0 for i in [0..maxk]}
		for i in [1..maxval]:
			val = quasi(i)
			if val <= maxk:
				ret[val] = i
		
		return ret
	
	def LengthSet(self, n, should_use_store_loc = True):
		if n not in self.__lengthsets:
			self.__lengthsets[n] = sorted(list(Set([sum(f) for f in self.Factorizations(n)])))
		
		return self.__lengthsets[n]
		# return self.__GenericGapCall(n, should_use_store_loc, self.__lengthsets, 'LengthsOfFactorizationsElementWRTNumericalSemigroup')
		# return [int(j) for j in gap('LengthsOfFactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name()))]
	
	def LengthSetsUpToElement(self, nmax):
		self.__lengthsets[0] = [0]
		
		for n in [1 .. nmax]:
			if n in self.__lengthsets:
				continue
			
			self.__lengthsets[n] = []
			
			for i in range(len(self.gens)):
				if n - self.gens[i] < 0:
					continue
				
				self.__lengthsets[n] += [l + 1 for l in self.__lengthsets[n - self.gens[i]]]
			
			self.__lengthsets[n] = sorted(list(Set(self.__lengthsets[n])))
	
	def LengthDensity(self, n = None):
		if n == None:
			bound = self.DeltaSetPeriodicityBound() + lcm(self.gens[0], self.gens[-1])
			self.LengthSetsUpToElement(bound)
			return min([self.LengthDensity(elem) for elem in [1 .. bound] if len(self.LengthSet(elem)) > 1])

		L = self.LengthSet(n)
		if len(L) == 1:
			return NaN
		
		return (len(L) - Rational(1))/(max(L) - min(L))

	def LengthSetPeriodicityBound(self):
		a = self.gens
		
		if len(a) == 1:
			return 1
		elif len(a) == 2:
			return (a[0] - 1)*(a[1] - 1)
		
		r = len(self.gens)
		d = min(self.DeltaSet())
		
		def _S_i(i):
			gcdRes = gcd(gcd(a[i] - a[0], a[0] - a[r-1]), a[r-1] - a[i])
			num = a[1] * (a[0] * d * gcdRes + (r-2)*(a[0] - a[i])*(a[0] - a[r-1]))
			denom = (a[0] - a[1]) * gcdRes
			
			return - (num / denom)

		def _Sprime_i(i):
			gcdRes = gcd(gcd(a[i] - a[0], a[0] - a[r-1]), a[r-1] - a[i])
			num = a[r-2]*((r - 2)*(a[0] - a[r-1])*(a[r-1] - a[i]) - d*a[r-1]*gcdRes)
			denom = (a[r-2] - a[r-1])*gcdRes
			
			return num/denom

		S_i = []
		Sprime_i = []
		for i in range(1, len(a)):
			S_i.append(_S_i(i))
			Sprime_i.append(_Sprime_i(i))
		
		return ceil(max(max(S_i), max(Sprime_i)))

	def LengthSetPeriodicityStart(self):
		if len(self.gens) == 1:
			return 1
		n1 = self.gens[0]
		nr  = self.gens[len(self.gens) - 1]
		lcmRes = lcm(n1, nr)
		
		g = gcd([self.gens[i+1] - self.gens[i] for i in range(len(self.gens)-1)])
		a1 = ((nr - n1) * lcmRes)/(g*nr*n1)
		i = self.LengthSetPeriodicityBound()
		
		self.LengthSetsUpToElement(i + lcmRes)
		
		while i in self and len(self.LengthSet(i + lcmRes)) - len(self.LengthSet(i)) == a1:
			i -= 1
		return i + 1
	
	def WeightVector(self):
		return self.__weight
	
	def SetWeightVector(self, w):
		if len(w) != len(self.gens):
			raise ValueError("Weight vector is the wrong length")
		
		if w != self.__weight:
			self.__weight = w
			self.__weightedlengthsets = {}
	
	def WeightedLengthSet(self, n, should_use_store_loc = True):
		if n not in self.__weightedlengthsets:
			self.__weightedlengthsets[n] = sorted(list(Set([sum([i*j for (i,j) in zip(f,self.__weight)]) for f in self.Factorizations(n)])))
		
		return self.__weightedlengthsets[n]
	
	def WeightedLengthSetsUpToElement(self, nmax):
		self.__weightedlengthsets[0] = [0]
		
		for n in [1 .. nmax]:
			if n in self.__weightedlengthsets:
				continue
			
			self.__weightedlengthsets[n] = []
			
			for i in range(len(self.gens)):
				if n - self.gens[i] < 0:
					continue
				
				self.__weightedlengthsets[n] += [l + self.__weight[i] for l in self.__weightedlengthsets[n - self.gens[i]]]
			
			self.__weightedlengthsets[n] = sorted(list(Set(self.__weightedlengthsets[n])))
	
	def WeightedMaxLength(self, n):
		if n in self.__weightedmaxlengths:
			return self.__weightedmaxlengths[n]
		else:
			return max(self.WeightedLengthSet(n))
		
	
	def WeightedMaxLengthsUpToElement(self, nmax):
		self.__weightedmaxlengths[0] = 0
		
		for n in [1 .. nmax]:
			if n in self.__weightedmaxlengths:
				continue
			
			if n in self.__weightedlengthsets:
				self.__weightedmaxlengths[n] = max(self.WeightedLengthSet(n))
				continue
			
			self.__weightedmaxlengths[n] = max([0] + [self.__weightedmaxlengths[n-self.gens[i]]+self.__weight[i] for i in range(len(self.gens)) if n-self.gens[i] >= 0])
	
	def LengthSetQuasipolynomial(self):
		if self.__lensetquasi == None:
			maxval = self.DeltaSetPeriodicityBound() + 2*lcm(self.gens)
			snm = self.semigroup.name()
			
			gcomm = 'List([1..%d], function(i) if not(i in %s) then return 0; else return Length(LengthsOfFactorizationsElementWRTNumericalSemigroup(i,%s)); fi; end)'
			lencountlist = [1] + ConvertGapToSage(gap(gcomm % (maxval,snm,snm)))
			
			self.__lensetquasi = Quasipolynomial.FromCoefficients(lencountlist, lcm(self.gens[0], self.gens[-1]), 1)
		
		return self.__lensetquasi
	
	def DeltaSet(self, n = None, should_use_affine_alg = True, should_use_store_loc = True):
		if n == None:
			if should_use_affine_alg:
				affinestr = 'DeltaSetOfAffineSemigroup(AffineSemigroupByGenerators(%s))' % ",".join(['[%d]' % g for g in self.gens])
				return self.__GenericGapCallGlobal(should_use_store_loc, self.__deltaset, affinestr, insert_inputs=False)
			else:
				return self.__GenericGapCallGlobal(should_use_store_loc, self.__deltaset, 'DeltaSetOfNumericalSemigroup')
		
		if n not in self.__deltasets:
			self.__deltasets[n] = DeltaSetFromLengthSet(self.LengthSet(n))
		
		return self.__deltasets[n]
		# return self.__GenericGapCall(n, should_use_store_loc, self.__deltasets, 'DeltaSetOfFactorizationsElementWRTNumericalSemigroup')
		# return [int(j) for j in gap('DeltaSetOfFactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name()))]
	
	def DeltaSetPeriodicityBound(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__deltasetperiodicitybound, 'DeltaSetPeriodicityBoundForNumericalSemigroup')
	
	def DeltaSetPeriodicityStart(self, should_use_store_loc = True):
		return self.__GenericGapCallGlobal(should_use_store_loc, self.__deltasetperiodicitystart, 'DeltaSetPeriodicityStartForNumericalSemigroup')
	
	def DeltaSetUnionUpToElement(self, nmax):
		self.LengthSetsUpToElement(nmax)
		
		retset = []
		for n in [1 .. nmax]:
			retset += self.DeltaSet(n)
		
		return Set(retset)
	
	def DeltaSetRingBufferUpToElement(self, nmax):
		g1 = self.gens[0]
		gk = max(self.gens)
		totalperiod = lcm(g1,gk)
		
		lensetringbuffer = [[] for i in [1 .. gk]]
		lensetringbuffer[0] = [0]
		
		deltasetringbuffer = [[] for i in [1 .. totalperiod]]
		
		dissonance = 0
		retset = Set([])
		for n in [1 .. nmax]:
			lenset = []
			for i in range(len(self.gens)):
				lenset += [l + 1 for l in lensetringbuffer[(n - self.gens[i]) % gk]]
			
			lenset = sorted(list(Set(lenset)))
			deltaset = DeltaSetFromLengthSet(lenset)
			lensetringbuffer[n % gk] = lenset
			retset += deltaset
			
			if deltaset != deltasetringbuffer[n % totalperiod]:
				dissonance = n - totalperiod
			
			deltasetringbuffer[n % totalperiod] = deltaset
		
		return (retset,dissonance)
	
	def CatenaryGraph(self, s):
		factorizations = [tuple(f) for f in self.Factorizations(s)]
		G = Graph()
		G.add_vertices(factorizations)
		for v1 in factorizations:
			for v2 in factorizations:
				if v1 != v2:
					lv1 = list(v1)
					lv2 = list(v2)
					for i in range(len(self.gens)):
						m = min(lv1[i], lv2[i])
						lv1[i] -= m
						lv2[i] -= m
					d = max(sum(lv1), sum(lv2))
					G.add_edge([v1, v2, d])
		return G
	
	def PlotCatenaryGraph(self, n):
		G = self.CatenaryGraph(n)
		edge_colors = {'#ffaaaa':[], 'black':[], '#aaaaff':[]}
		for e in G.edges():
			if e[2] < self.CatenaryDegree(n):
				edge_colors['#aaaaff'].append(e)
			elif e[2] == self.CatenaryDegree(n):
				edge_colors['black'].append(e)
			else:
				edge_colors['#ffaaaa'].append(e)
		return G.plot(edge_labels=True, layout="circular", vertex_size=2000, edge_colors=edge_colors)
	
	def CatenaryDegree(self, n = None, should_use_store_loc = True):
		if n == None:
			if self.__IsCallSaved(self.__bettielements):
				return max([self.CatenaryDegree(i) for i in self.BettiElements()])
			else:
				return self.__GenericGapCallGlobal(should_use_store_loc, self.__catenarydegree, 'CatenaryDegreeOfNumericalSemigroup')
		else:
			return self.__GenericGapCall(n, should_use_store_loc, self.__catenaries, 'CatenaryDegreeOfElementInNumericalSemigroup')
		# return int(gap('CatenaryDegreeOfElementInNumericalSemigroup(%d,%s)'%(n,self.semigroup.name())))
	
	# def CatenaryDegreesUpToElement(self, nmax):
	# 	# determine which elements are missing
	# 	mvals = [i for i in [1..nmax] if i in self and i not in self.__catenaries]
		
	# 	# call to find catenary degrees
	# 	for output in Internal_ParallelCatenaryDegrees([(self.gens,i) for i in mvals]):
	# 		print(output)
	# 		# self.__catenaries[] = 
		
	# 	return
	
	def EqualCatenaryDegree(self, n = None, should_use_store_loc = True):
		if n == None:
			return self.__GenericGapCallGlobal(should_use_store_loc, self.__equalcatenarydegree, 'EqualCatenaryDegreeOfNumericalSemigroup')
		else:
			return self.__GenericGapCall(n, should_use_store_loc, self.__equalcatenaries, 'EqualCatenaryDegreeOfElementInNumericalSemigroup')
	
	def AdjacentCatenaryDegree(self, n, should_use_store_loc = True):
		return self.__GenericGapCall(n, should_use_store_loc, self.__adjacentcatenaries, 'AdjacentCatenaryDegreeOfElementInNumericalSemigroup')
	
	def MonotoneCatenaryDegree(self, n = None, should_use_store_loc = True):
		# if n == None:
		# 	return 0
		# else:
		# 	if should_use_store_loc and (n in self.__equalcatenaries or n in self.__adjacentcatenaries):
		# 		return max([self.EqualCatenaryDegree(n, should_use_store_loc) and self.AdjacentCatenaryDegree(n, should_use_store_loc)])
			
		# 	degrees = self.__GenericGapCall(n, should_use_store_loc, self.__equalcatenaries, 'EqualAndAdjacentCatenaryDegreesOfElementInNumericalSemigroup')
			
		# 	if should_use_store_loc:
		# 		self.__equalcatenaries[n] = degrees[0]
		# 		self.__adjacentcatenaries[n] = degrees[1]
			
		# 	return max(degrees)
		if n == None:
			return self.__GenericGapCallGlobal(should_use_store_loc, self.__monotonecatenarydegree, 'MonotoneCatenaryDegreeOfNumericalSemigroup')
		else:
			if should_use_store_loc and (n in self.__monotonecatenaries.keys()):
				return self.__monotonecatenaries[n]
			
			ret = ConvertGapToSage(gap('MonotoneCatenaryDegreeOfSetOfFactorizations(FactorizationsIntegerWRTList(%d,%s));'%(n,str(self.gens))))
			
			if should_use_store_loc:
				self.__monotonecatenaries[n] = ret
			
			return ret
	
	def TameDegree(self, n = None, should_use_store_loc = True):
		if n == None:
			return self.__GenericGapCallGlobal(should_use_store_loc, self.__tamedegree, 'TameDegreeOfNumericalSemigroup')
		else:
			return self.__GenericGapCall(n, should_use_store_loc, self.__tamedegrees, 'TameDegreeOfElementInNumericalSemigroup')
		# return int(gap('CatenaryDegreeOfElementInNumericalSemigroup(%d,%s)'%(n,self.semigroup.name())))
	
	#def CatenaryDegree(self):
	#	return int(gap('CatenaryDegreeOfNumericalSemigroup(%s)'%(self.semigroup.name())))
	
	def Elasticity(self, n, should_use_store_loc = True):
		if n == oo:
			return self.__GenericGapCallGlobal(should_use_store_loc, self.__elasticity, 'ElasticityOfNumericalSemigroup')
		elif n <= self.gens[-1]*self.gens[-2] + self.gens[-1]:
			return max(self.LengthSet(n))/min(self.LengthSet(n))
		else:
			nn1 = ((n - self.gens[-1]*self.gens[-2])%self.gens[0])+self.gens[-1]*self.gens[-2]
			nnk = ((n - self.gens[-1]*self.gens[-2])%self.gens[-1])+self.gens[-1]*self.gens[-2]
			nmult1 = (n - nn1)/(self.gens[0])
			nmultk = (n - nnk)/(self.gens[-1])
			return (max(self.LengthSet(nn1)) + nmult1)/(min(self.LengthSet(nnk)) + nmultk)
		# return Rational(gap('ElasticityOfFactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name())))
	
	def OldElasticity(self,n,should_use_store_loc = True):
		if n == oo:
			return self.__GenericGapCallGlobal(should_use_store_loc, self.__elasticity, 'ElasticityOfNumericalSemigroup')
		else:
			return self.__GenericGapCall(n, should_use_store_loc, self.__elasticities, 'ElasticityOfFactorizationsElementWRTNumericalSemigroup')
		# return Rational(gap('ElasticityOfFactorizationsElementWRTNumericalSemigroup(%d,%s)'%(n,self.semigroup.name())))
	
	def SpecialElasticity(self, i, should_use_store_loc = True):
		elements = [0]
		for j in range(0,i):
			elements = [a+g for a in elements for g in self.gens]
		
		return max([max(self.LengthSet(a)) for a in elements])
	
	def SetOfElasticities(self, elastuppererror):
		g1 = self.gens[0]
		gk = self.gens[-1]
		elast = Rational(gk)/Rational(g1)
		noisebound = gk*self.gens[-2]
		
		self.LengthSetsUpToElement(noisebound + g1*gk)
		
		ret = []
		for i in [1 .. noisebound-1]:
			if i in self and self.Elasticity(i) <= elast - elastuppererror:
				ret.append(self.Elasticity(i))
		
		for i in range(g1*gk):
			top = max(self.LengthSet(noisebound + (i % g1))) + int(i/g1)
			bottom = min(self.LengthSet(noisebound + i % gk)) + int(i/gk)
			while (top/bottom) <= elast - elastuppererror:
				ret.append(top/bottom)
				top += gk
				bottom += g1
		
		return Set(ret)
	
	def SetOfElasticityFractions(self, elastuppererror):
		g1 = self.gens[0]
		gk = self.gens[-1]
		elast = Rational(gk)/Rational(g1)
		noisebound = gk*self.gens[-2]
		
		self.LengthSetsUpToElement(noisebound + g1*gk)
		
		ret = []
		for i in [1 .. noisebound-1]:
			if i in self and self.Elasticity(i) <= elast - elastuppererror:
				ret.append((max(self.LengthSet(i)),min(self.LengthSet(i))))
		
		for i in range(g1*gk):
			top = max(self.LengthSet(noisebound + (i % g1))) + int(i/g1)
			bottom = min(self.LengthSet(noisebound + i % gk)) + int(i/gk)
			while (top/bottom) <= elast - elastuppererror:
				ret.append((top,bottom))
				top += gk
				bottom += g1
		
		return Set(ret)
	
	def OmegaPrimality(self, n, should_use_store_loc = True):
		return self.__GenericGapCall(n, should_use_store_loc, self.__omegas, 'OmegaPrimalityOfElementInNumericalSemigroup')
		#if not(n in self.__omegas.keys()):
		#	if self.Contains(n):
		#		self.__omegas[n] = int(gap('OmegaPrimalityOfElementInNumericalSemigroup(%d,%s)'%(n,self.semigroup.name())))
		#	else:
		#		self.__omegas[n] = 0
		#
		#return self.__omegas[n]
	
	def OmegaCumulative(self, maxval, should_use_store_loc = True):
		inlist = [-self.FrobeniusNumber() .. maxval]
		outlist = gap('OmegaPrimalityOfElementListInNumericalSemigroup([%d .. %d],%s)'%(inlist[0],inlist[-1],self.semigroup.name()))
		# outlist = self.__GenericGapCall(inlist, False, None, 'OmegaPrimalityOfElementListInNumericalSemigroup')
		
		for (i,j) in zip(inlist,outlist):
			self.__omegas[i] = int(j)
	
	def OmegaQuasilinearityDissonance(self):
		bound = self.OmegaQuasilinearityBound()
		self.OmegaCumulative(bound+self.gens[0])
		return max([i for i in [-self.FrobeniusNumber() .. bound] if self.__omegas[i] + 1 != self.__omegas[i+self.gens[0]]])
		# gap.eval('afirstgen:=%d; Lallomegas:=OmegaPrimalityOfElementListInNumericalSemigroup([1 .. %d], %s);'%(self.gens[0],self.OmegaQuasilinearityBound()+self.gens[0],self.semigroup.name()))
		# return int(gap('Maximum(Filtered([1..Length(Lallomegas)-afirstgen], i -> not(Lallomegas[i+afirstgen]-1 = Lallomegas[i])))'))
	
	def OmegaQuasilinearityBound(self):
		return (self.FrobeniusNumber() + self.gens[1])*self.gens[0]/(self.gens[1]-self.gens[0])
	
	@staticmethod
	def FromKunzCoordinates(coords):
		m = len(coords)+1
		S = NumericalSemigroup([m] + [coords[i]*m + (i+1) for i in range(len(coords))])
		
		return S
	
	@staticmethod
	def SemigroupsWithFrobeniusNumber(f):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('NumericalSemigroupsWithFrobeniusNumber(' + str(f) + ')')]
		#for s in gap('NumericalSemigroupsWithFrobeniusNumber(' + str(f) + ')'):
		#	semi = NumericalSemigroup()
		#	semi.__InitWithGapSemigroup(s)
		#	ret.append(semi)
		#return ret
	
	@staticmethod
	def SemigroupsWithPseudoFrobeniusNumbers(pf):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('NumericalSemigroupsWithPseudoFrobeniusNumbers(' + str(pf) + ')')]
	
	@staticmethod
	def SemigroupsWithGenus(g):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('NumericalSemigroupsWithGenus(' + str(g) + ')')]
	
	@staticmethod
	def ArfSemigroupsWithFrobeniusNumber(f):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('ArfNumericalSemigroupsWithFrobeniusNumber(' + str(f) + ')')]
	
	@staticmethod
	def ArfSemigroupsWithGenus(g):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('ArfNumericalSemigroupsWithGenus(' + str(g) + ')')]
	
	@staticmethod
	def IrreducibleSemigroupsWithFrobeniusNumber(f):
		return [NumericalSemigroup().__InitWithGapSemigroup(s) for s in gap('IrreducibleNumericalSemigroupsWithFrobeniusNumber(' + str(f) + ')')]
	
	@staticmethod
	def SemigroupsWithGeneratorBounds(emb,nmax):
		values = [[i] for i in [emb .. nmax]]
		totest = values
		
		for i in range(emb-1):
			totest = [k + j for k in values for j in totest if k[0] < j[0]]
		
		totest = [l for l in totest if gcd(l) == 1]
		ret = [NumericalSemigroup(l) for l in totest]
		return {tuple(S.gens):S for S in ret if len(S.gens) == emb}
	
	@staticmethod
	def RandomSemigroup(maxemb,genmax):
		params = [str(maxemb), str(genmax)]
		return NumericalSemigroup().__InitWithGapSemigroup(gap('RandomNumericalSemigroup(%s)'%(','.join(params))))
	
	def RandomSemigroupWithGenus(genus):
		params = [str(genus)]
		return NumericalSemigroup().__InitWithGapSemigroup(gap('RandomNumericalSemigroupWithGenus(%s)'%(','.join(params))))

	def __eq__(self, other):
		return self.gens == other.gens
	
	def __ne__(self, other):
		return self.gens != other.gens
	
	def __contains__(self,other):
		return self.Contains(other)
	
	def __repr__(self):
		return "Numerical Semigroup generated by " + str(self.gens)
	
	def __str__(self):
		return self.SaveToString()
	
	
	
	
	
# 	############################################################################
# 	######### ONGOING OMEGA-PRIMALITY STUFF - USE AT YOUR OWN RISK! ############
# 	############################################################################
	
# 	def Internal_OmegaManualBullets(self,n):
# 		bounds = [max([k + n for k in self.__aperygens[self.gens[i]] if (k + n) % self.gens[i] == 0])/self.gens[i] for i in range(len(self.gens))]
		
# 		bullet = [0 for i in range(len(self.gens))]
# 		toret = []
		
# 		bullet = bullet
# 		bounds = bounds
		
# 		while True:
# 			# check if its a bullet
# 			bulval = sum([bullet[i]*self.gens[i] for i in range(len(self.gens))])
# 			if self.Contains(bulval - n) and all([(bullet[i] == 0 or not(self.Contains(bulval - n - self.gens[i]))) for i in range(len(self.gens))]):
# 				toret.append([i for i in bullet])
			
# 			# increment
# 			# MUST IMPROVE
# 			for i in range(len(self.gens)):
# 				bullet[i] = bullet[i] + 1
# 				if bullet[i] <= bounds[i]:
# 					break
				
# 				bullet[i] = 0
			
# 			if max(bullet) == 0:
# 				break
		
# 		# self.__bullets[n] = toret
		
# 		return toret
	
# 	def Internal_OmegaDynamicBullets(self,n):
# 		if n in self.__bullets.keys():
# 			return self.__bullets[n]
		
# 		if n < -self.FrobeniusNumber():
# 			return [[0 for j in range(len(self.gens))]]
		
# 		#if n <= 0:
# 		#	self.__bullets[n] = self.Internal_OmegaManualBullets(n)
# 		#	return self.__bullets[n]
		
# 		toret = set([])
# 		omegaret = 0
		
# 		for i in range(len(self.gens)):
# 			for bullet in self.Internal_OmegaDynamicBullets(n - self.gens[i]):
# 				toadd = list(bullet)
				
# 				bulval = sum([bullet[j]*self.gens[j] for j in range(len(self.gens))])
# 				omegaval = sum([bullet[j] for j in range(len(self.gens))])
# 				if bullet[i] > 0 or not(self.Contains(bulval - n)):
# 					toadd[i] = toadd[i] + 1
# 					omegaval = omegaval + 1
				
# 				# ensure we dont already have it before we add it
# 				if not(tuple(toadd) in toret):
# 					toret = toret.union([tuple(toadd)])
					
# 					if omegaval > omegaret:
# 						omegaret = omegaval
		
# 		self.__bullets[n] = list(toret)
# 		self.__omegas[n] = omegaret
		
# 		return self.__bullets[n]
		
	
# 	def Internal_OmegaPrimalityGap(self,n,nmax=n):
# 		return ConvertGapToSage(gap('OmegaPrimalityOfElementListInNumericalSemigroup([%d..%d],%s);'%(n,nmax,self.semigroup.name())))
	
# 	def Internal_OmegaBullets(self, n):
# 		return self.Internal_OmegaDynamicBullets(n)
# 	'''
# 	def OmegaBullets(self, n):
# 		if n in self.__bullets.keys():
# 			return self.__bullets[n]
		
# 		omega = self.OmegaPrimality(n)
		
# 		toret = []
		
# 		if len(self.gens) == 2:
# 			for a in (0 .. omega):
# 				for b in (0 .. omega-a):
# 					ret = [b,a]
# 					bullet = sum([ret[i]*self.gens[i] for i in range(len(self.gens))])
					
# 					if self.Contains(bullet - n) and all([(ret[i] == 0 or not(self.Contains(bullet - n - self.gens[i]))) for i in range(len(self.gens))]):
# 						toret.append(ret)
		
# 		if len(self.gens) == 3:
# 			for a in (0 .. omega):
# 				for b in (0 .. omega-a):
# 					for c in (0 .. omega-a-b):
# 						ret = [c,b,a]
# 						bullet = sum([ret[i]*self.gens[i] for i in range(len(self.gens))])
						
# 						if self.Contains(bullet - n) and all([(ret[i] == 0 or not(self.Contains(bullet - n - self.gens[i]))) for i in range(len(self.gens))]):
# 							toret.append(ret)
		
# 		if len(self.gens) == 4:
# 			for a in (0 .. omega):
# 				for b in (0 .. omega-a):
# 					for c in (0 .. omega-a-b):
# 						for d in (0 .. omega-a-b-c):
# 							ret = [d,c,b,a]
# 							bullet = sum([ret[i]*self.gens[i] for i in range(len(self.gens))])
							
# 							if self.Contains(bullet - n) and all([(ret[i] == 0 or not(self.Contains(bullet - n - self.gens[i]))) for i in range(len(self.gens))]):
# 								toret.append(ret)
		
# 		self.__bullets[n] = toret
		
# 		return toret
# 	'''
	
# 	def Internal_OmegaMaxBullets(self, n):
# 		if not(n in self.__maxbullets.keys()):
# 			self.__maxbullets[n] = [bul for bul in self.Internal_OmegaBullets(n) if sum(bul) == self.OmegaPrimality(n)]
		
# 		return self.__maxbullets[n]
	
# 	def Internal_HTMLOmegaTable(self,nmax,splits = 0):
# 		if splits == 0:
# 			splits = min(self.gens)
		
# 		table = []
# 		nmax = nmax - (nmax % splits)
		
# 		for i in (1 .. nmax):
# 			if not(i in self.gaps):
# 				bullets = self.OmegaMaxBullets(i)
# 				if len(bullets) == 0:
# 					table.append([i, self.OmegaPrimality(i), '', ''])
# 				else:
# 					table.append([i, self.OmegaPrimality(i), (bullets[0],len(bullets)), ''])
# 			else:
# 				table.append(['','','',''])
		
# 		# nmax = len(table)
# 		# nmax = nmax - (nmax % splits)
		
# 		table = [[k for j in range(splits) for k in ['n','Omega(n)','maxbullet','']][:-1]]
# 		table = table + [[k for j in range(splits) for k in table[splits*i + j]][:-1] for i in range(nmax/splits)]
		
# 		return html.table(table)
	
# 	def PlotOmegaValues(self,maxval):
# 		pointList = []
		
# 		self.OmegaCumulative(maxval)
		
# 		for i in range(0,maxval):
# 			if i in self:
# 				pointList.append((i,self.OmegaPrimality(i)))
		
# 		return points(pointList, size=40)
	
	

NumericalSemigroup.KFrobeniusNumbers = NumericalSemigroup.FrobeniusNumbers


############################################################################
############ HARDCODED GAP FUNCTIONS, UNTIL THEY ARE ADDED! ################
############################################################################

GAPCODESTR_OTHERCATENARYDEGREES = '''

LoadPackage("4ti2");
LoadPackage("IO")



###################################################################
#F  AdjacentCatenaryDegreeOfSetOfFactorizations(ls)
## computes the adjacent catenary degree of the set of factorizations ls
###################################################################
AdjacentCatenaryDegreeOfSetOfFactorizations:=function(ls)
	local distance, Fn, lenset, Zi, facti, i;


	if not(IsRectangularTable(ls) and IsListOfIntegersNS(ls[1])) then
		Error("The argument is not a list of factorizations.");
	fi;

	# Tomado de CatenaryDegreeOfElementInNumericalSemigroup_NC
	# distance between two factorizations
	distance:=function(x,y)
		local p,n,i,z;

		p:=0; n:=0;
		z:=x-y;
		for i in [1..Length(z)] do
			if z[i]>0 then
				p:=p+z[i];
			else
				n:=n+z[i];
			fi;
		od;

		return Maximum(p,-n);
	end;    

	Fn:=Set(ShallowCopy(ls));
	lenset:=Set( ls, Sum );
	if Length(lenset)=1 then 
	return 0;
	fi;
	Zi:=[];
	for i in lenset do
		facti:=Filtered( Fn, x->Sum(x)=i );
		SubtractSet( Fn, facti );
		Add( Zi, facti );
	od;
	return Maximum( List( [2..Length( Zi )], t->Minimum( List( Zi[t-1], x->Minimum( List( Zi[t], y->distance( x, y ) ) ) ) ) ) );
end;


###################################################################
#F EqualCatenaryDegreeOfSetOfFactorizations(ls) 
## computes the equal catenary degree of of the set of factorizations
###################################################################
EqualCatenaryDegreeOfSetOfFactorizations:=function(ls)
	local distance, lFni;

	if not(IsRectangularTable(ls) and IsListOfIntegersNS(ls[1])) then
		Error("The argument is not a list of factorizations.");
	fi;

 
   # distance between two factorizations
	distance:=function(x,y)
		local p,n,i,z;

		p:=0; n:=0;
		z:=x-y;
		for i in [1..Length(z)] do
			if z[i]>0 then
				p:=p+z[i];
			else
				n:=n+z[i];
			fi;
		od;

		return Maximum(p,-n);
	end;    


	lFni:=Set( ls, t->Sum( t ) );
	return Maximum( List( lFni, y->CatenaryDegreeOfSetOfFactorizations( Filtered( ls, x->Sum( x )=y ) ) ) );
end;

###################################################################
#F MonotoneCatenaryDegreeOfSetOfFactorizations(ls) 
## computes the equal catenary degree of of the set of factorizations
###################################################################
MonotoneCatenaryDegreeOfSetOfFactorizations:=function(ls)
	return Maximum(AdjacentCatenaryDegreeOfSetOfFactorizations(ls), 
		EqualCatenaryDegreeOfSetOfFactorizations( ls ));
end;

#############################################################################
#F  MonotonePrimitiveElementsOfNumericalSemigroup(s)
##
## Computes the sets of elements in s, such that there exists a minimal 
## solution to msg*x-msg*y = 0, |x|<=|y| such tht x,y are factorizations of s
##
#############################################################################

MonotonePrimitiveElementsOfNumericalSemigroup:=function(s)
	local l, n, facs, mat, ones;

	if not IsNumericalSemigroup(s) then
		Error("The argument must be a numerical semigroup.");
	fi;

	if LoadPackage("4ti2interface")=false then
		Error("This function requires 4ti2interface package");
	fi;

	l:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	n:=Length(l);
	ones:=List([1..n],_->1);
	mat:=[];
	mat[1]:=Concatenation(l,-l,[0]);
	mat[2]:=Concatenation(ones,-ones,[1]);
	facs:=Set(4ti2Interface_hilbert_equalities_in_positive_orthant(mat),m->m{[1..n]});
	return Set(facs, f-> f*l);
end;

#####
# graver version, 4ti2
#####
MonotonePrimitiveElementsOfNumericalSemigroup_graver:=function(s)
	local dir, filename, exec, filestream, matrix,
				l, n,  facs, mat, trunc;
	
	dir := DirectoryTemporary();
	filename := Filename( dir, "gap_4ti2_temp_matrix" );

	l:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	n:=Length(l);
	mat:=[];
	mat[1]:=Concatenation(l,[0]);
	mat[2]:=List([1..n+1],_->1);
	4ti2Interface_Write_Matrix_To_File( mat, Concatenation( filename, ".mat" ) );
	exec := IO_FindExecutable( "graver" );
	filestream := IO_Popen2( exec, [ filename ]);
	while IO_ReadLine( filestream.stdout ) <> "" do od;
	matrix := 4ti2Interface_Read_Matrix_From_File( Concatenation( filename, ".gra" ) );

	trunc:=function(ls)
		return List(ls, y->Maximum(y,0));
	end;

	matrix:=Set(matrix,trunc);
	return Set(matrix, x->x{[1..n]}*l);

end;

#############################################################################
#F  PrimitiveElementsOfNumericalSemigroup(s)
##
## Computes the sets of elements in s, such that there exists a minimal 
## solution to msg*x-msg*y = 0,  such that x,y are factorizations of s
##
#############################################################################
PrimitiveElementsOfNumericalSemigroup:=function(s)
	local l, n, facs, mat;

	if not IsNumericalSemigroup(s) then
		Error("The argument must be a numerical semigroup.");
	fi;


	l:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	n:=Length(l);
	mat:=[Concatenation(l,-l)];
	facs:=Set(4ti2Interface_hilbert_equalities_in_positive_orthant(mat),m->m{[1..n]});
	return Set(facs, f-> f*l);
end;

#####
# graver version, 4ti2
#####
PrimitiveElementsOfNumericalSemigroup_graver:=function(s)
	local dir, filename, exec, filestream, matrix,
				l,  facs, mat, trunc;
	
	dir := DirectoryTemporary();
	filename := Filename( dir, "gap_4ti2_temp_matrix" );

	l:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	mat:=[l];
	4ti2Interface_Write_Matrix_To_File( mat, Concatenation( filename, ".mat" ) );
	exec := IO_FindExecutable( "graver" );
	filestream := IO_Popen2( exec, [ filename ]);
	while IO_ReadLine( filestream.stdout ) <> "" do od;
	matrix := 4ti2Interface_Read_Matrix_From_File( Concatenation( filename, ".gra" ) );

	trunc:=function(ls)
		return List(ls, y->Maximum(y,0));
	end;

	matrix:=Set(matrix,trunc);
	return Set(matrix, x->x*l);
end;


#####
# graver version, 4ti2
#####
EqualPrimitiveElementsOfNumericalSemigroup:=function(s)
	local dir, filename, exec, filestream, matrix,
				l,  facs, mat, trunc;
	
	dir := DirectoryTemporary();
	filename := Filename( dir, "gap_4ti2_temp_matrix" );

	l:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	mat:=[l];
	mat[2]:=List([1..Length(l),_->1);

	4ti2Interface_Write_Matrix_To_File( mat, Concatenation( filename, ".mat" ) );
	exec := IO_FindExecutable( "graver" );
	filestream := IO_Popen2( exec, [ filename ]);
	while IO_ReadLine( filestream.stdout ) <> "" do od;
	matrix := 4ti2Interface_Read_Matrix_From_File( Concatenation( filename, ".gra" ) );

	trunc:=function(ls)
		return List(ls, y->Maximum(y,0));
	end;

	matrix:=Set(matrix,trunc);
	return Set(matrix, x->x*l);
end;


####################################################################
#F AdjacentCatenaryDegreeOfNumericalSemigroup(s) computes the 
##  adjacent catenary degree of the numerical semigroup s
##  the adjacent catenary degree is reached in the set of primitive
##  elements of s (see [PH])
####################################################################
AdjacentCatenaryDegreeOfNumericalSemigroup:=function(s)
	local prim, msg;
	if not IsNumericalSemigroup(s) then
		Error("The argument must be a numerical semigroup.");
	fi;

	msg:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	prim:=MonotonePrimitiveElementsOfNumericalSemigroup(s);

	return Maximum(Set(prim, n-> AdjacentCatenaryDegreeOfSetOfFactorizations(
				FactorizationsIntegerWRTList(n,msg))));
end;

####################################################################
#F EqualCatenaryDegreeOfNumericalSemigroup(s) computes the 
##  adjacent catenary degree of the numerical semigroup s
##  the equal catenary degree is reached in the set of primitive
##  elements of s (see [PH])
####################################################################
EqualCatenaryDegreeOfNumericalSemigroup:=function(s)
	local prim, msg;
	if not IsNumericalSemigroup(s) then
		Error("The argument must be a numerical semigroup.");
	fi;

	msg:=EqualMinimalGeneratingSystemOfNumericalSemigroup(s);
	prim:=PrimitiveElementsOfNumericalSemigroup(s);

	return Maximum(Set(prim, n-> EqualCatenaryDegreeOfSetOfFactorizations(
				FactorizationsIntegerWRTList(n,msg))));
end;

####################################################################
#F MonotoneCatenaryDegreeOfNumericalSemigroup(s) computes the 
##  adjacent catenary degree of the numerical semigroup s
##  the monotone catenary degree is reached in the set of primitive
##  elements of s (see [PH])
####################################################################
MonotoneCatenaryDegreeOfNumericalSemigroup:=function(s)
	local prim, msg;
	if not IsNumericalSemigroup(s) then
		Error("The argument must be a numerical semigroup.");
	fi;

	msg:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	prim:=MonotonePrimitiveElementsOfNumericalSemigroup(s);

	return Maximum(Set(prim, n-> MonotoneCatenaryDegreeOfSetOfFactorizations(
				FactorizationsIntegerWRTList(n,msg))));
end;


#InstallGlobalFunction(AdjacentCatenaryDegreeOfSetOfFactorizations, );
#InstallGlobalFunction(EqualCatenaryDegreeOfSetOfFactorizations);
#InstallGlobalFunction(MonotoneCatenaryDegreeOfSetOfFactorizations);
#InstallGlobalFunction(MonotonePrimitiveElementsOfNumericalSemigroup);
#InstallGlobalFunction(PrimitiveElementsOfNumericalSemigroup);
#InstallGlobalFunction(AdjacentCatenaryDegreeOfNumericalSemigroup);
#InstallGlobalFunction(EqualCatenaryDegreeOfNumericalSemigroup);
#InstallGlobalFunction(MonotoneCatenaryDegreeOfNumericalSemigroup);


''' # GAPCODESTR_OTHERCATENARYDEGREES



GAPCODESTR_FASTOMEGA = '''

####################################################################
#F OmegaPrimalityOfElementListInNumericalSemigroup(l,s) computes the 
##  omega primality of a list l of elements in the numerical semigroup 
##  s by iteratively computing bullet sets 
####################################################################
OmegaPrimalityOfElementListInNumericalSemigroup:=function(l,s)
	local frob, msg, values, bullets, omegas, n, i, b, toadd, omegaval, bl, getbullets, setbullets, getomega, setomega;
	
	if not IsNumericalSemigroup(s) then
		Error("The argument must be a numerical semigroup.");
	fi;
	
	msg:=MinimalGeneratingSystemOfNumericalSemigroup(s);
	frob:=FrobeniusNumberOfNumericalSemigroup(s);
	
	values := [-frob .. Maximum(l)];
	bullets := List(values, x->[]);
	omegas := List(values, x->0);
	
	getbullets:=function(n)  #add base case
		if n < -frob then
			return [List(msg,x->0)];
		fi;
		return bullets[n+frob+1];
	end;
	
	setbullets:=function(n,bl)
		if n >= -frob then
			bullets[n+frob+1] := bl;
		fi;
	end;
	
	getomega:=function(n)
		if n < -frob then
			return 0;
		fi;
		return omegas[n+frob+1];
	end;
	
	setomega:=function(n,om)
		if n >= -frob then
			omegas[n+frob+1] := om;
		fi;
	end;
	
	for n in values do
		bl := [];
		
		for i in [1..Length(msg)] do
			for b in getbullets(n - msg[i]) do
				toadd := List(b);
				
				if toadd[i] > 0 or not(toadd*msg-n in s) then
					toadd[i] := toadd[i] + 1;
				fi;
				
				Add(bl,toadd);
			od;
		od;
		
		setbullets(n,Set(bl));
		setbullets(n-msg[Length(msg)],[]);
		
		setomega(n,Maximum(List(getbullets(n),x->Sum(x))));
		
		# for garbage collection
		# GASMAN("coillect");
	od;
	
	return List(l,x->getomega(x));
end;

''' # GAPCODESTR_FASTOMEGA



#tempfile = tmp_filename()
#open(tempfile,"w").write(GAPCODESTR_OTHERCATENARYDEGREES)
#gap('Read("' + tempfile + '");')


#tempfile = tmp_filename()
#open(tempfile,"w").write(GAPCODESTR_FASTOMEGA)
#gap.eval('Read("' + tempfile + '");')

#gap(GAPCODESTR_FASTOMEGA)
#for line in GAPCODESTR_FASTOMEGA.split('\n'):
#	gap.eval(line)

#print(gap('OmegaPrimalityOfElementListInNumericalSemigroup([0..1000],NumericalSemigroup("generators", [6,9,20]));'))

