using PreprocessMD: PreprocessMD

using Aqua: Aqua
using CSV: CSV
using DataFrames: DataFrames
using Downloads: Downloads
using Tables: Tables
using Test: Test

using DataFrames: DataFrame
using DataFrames: innerjoin
using DataFrames: summary
using PreprocessMD: add_label_column!
using PreprocessMD: pivot
using PreprocessMD: repr
using PreprocessMD: top_n_values
using Test: @testset
using Test: @test
using Test: @test_throws
using Test: @test_skip

@testset "PreprocessMD" verbose = false begin
	# All external file downloads

	url = "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv"
	PERSON = DataFrame(CSV.File.(Downloads.download("$url/person.csv")))
	DRUG = DataFrame(CSV.File.(Downloads.download("$url/drug_exposure.csv")))
	CONDITION = DataFrame(CSV.File.(Downloads.download("$url/condition_occurrence.csv")))
	DEATH = DataFrame(CSV.File.(Downloads.download("$url/death.csv")))

#=
	@testset "File IO" verbose = false begin
		@test summary(PERSON) == "100×18 DataFrame"
		@test names(PERSON) == [
			"person_id",
			"gender_concept_id",
			"year_of_birth",
			"month_of_birth",
			"day_of_birth",
			"birth_datetime",
			"race_concept_id",
			"ethnicity_concept_id",
			"location_id",
			"provider_id",
			"care_site_id",
			"person_source_value",
			"gender_source_value",
			"gender_source_concept_id",
			"race_source_value",
			"race_source_concept_id",
			"ethnicity_source_value",
			"ethnicity_source_concept_id",
		]

		@test summary(DRUG) == "18229×23 DataFrame"
		@test summary(CONDITION) == "16441×16 DataFrame"
	end
=#

	@testset "pivot()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin

			@testset "ArgumentError" verbose = false begin
			end
			@testset "DomainError" verbose = false begin
				for x in [DataFrame(), DataFrame(; x=[0, 1, 2, 3])]
					@test_throws DomainError pivot(x)
				end
			end
			@testset "MethodError" verbose = false begin
				for x in [12, 1.0, "", x -> x]
					#@test_throws MethodError pivot(x)
				end
			end
		end
	@testset "Table to DataFrame conversions" verbose = false begin
		mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
		mattbl = Tables.table(mat)

		pivot(mattbl)	
	
		@test true
		
	end
		@testset "Simple examples" verbose = false begin
			A = DataFrame(; a=[1, 2, 1], b=['x', 'y', 'y'])
			B = pivot(A, :a, :b)
			C = DataFrame(; a=[1, 2], x=[true, false], y=[true, true])
			@test B == C

			B = pivot(A, :a)
			@test B == C

			B = pivot(A)
			@test B == C

			B = pivot(A, "a", "b")
			@test B == C
		end
	end

	@testset "add_label_column!()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin

				# DataFrame definitions
				long = DataFrame(
					name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
					val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
				)
				short = pivot(long)
				X = DataFrame(; name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
				results = DataFrame(;
					name=["aaa", "bbb", "ccc", "eee"],
					x=[true, false, false, false],
					w=[true, true, false, true],
					y=[true, false, true, false],
					z=[false, false, true, false],
					q=[true, false, false, false],
					a=[false, false, true, false],
					LABEL=[false, true, true, false],
				)
				new = deepcopy(short)
				# @test_throws UndefVarError add_label_column!(new, X, :NONEXISTENT)
			end
			@testset "DomainError" verbose = false begin
				@test_throws DomainError add_label_column!(DataFrame(), DataFrame())
				@test_throws DomainError add_label_column!(DataFrame(), DataFrame(; x=[]))
				@test_throws DomainError add_label_column!(DataFrame(; x=[]), DataFrame())
				@test_throws DomainError add_label_column!(
					DataFrame(; x=[]), DataFrame(; x=[])
				)
				@test_throws DomainError add_label_column!(
					DataFrame(; x=[1, 2]), DataFrame(; x=[])
				)
				@test_throws DomainError add_label_column!(
					DataFrame(; x=[]), DataFrame(; x=[1, 2])
				)
			end
			@testset "MethodError" verbose = false begin
				y = DataFrame(x=[1, 2, 3], y=['a', 'b', 'c'])
				for x in [12, 1.0, "", x -> x]
					# @test_throws MethodError add_label_column!(x, x)
					# @test_throws MethodError add_label_column!(x, y)
					# @test_throws MethodError add_label_column!(y, x)
				end
			end
		end
	@testset "Table to DataFrame conversions" verbose = false begin
	
	@testset "NonTable" verbose = false begin

		@test_throws ArgumentError add_label_column!(12, 12)
	end
	@testset "Table" verbose = false begin

		mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
		mattbl = Tables.table(mat)

			X = DataFrame(name=["bbb", "ccc"], r=["BBB", "CCC"], Column1=[1, 2])
	
			add_label_column!(mattbl, X, :Column1)
		#Tables.getcolumn(mattbl, :Column3) |> display
		@test true
	end
		
	end
		@testset "Default options" verbose = false begin

			# DataFrame definitions
			long = DataFrame(
				name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
				val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
			)
			short = pivot(long)
			X = DataFrame(name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
			results = DataFrame(
				name=["aaa", "bbb", "ccc", "eee"],
				x=[true, false, false, false],
				w=[true, true, false, true],
				y=[true, false, true, false],
				z=[false, false, true, false],
				q=[true, false, false, false],
				a=[false, false, true, false],
				LABEL=[false, true, true, false],
			)
			new = deepcopy(short)

			add_label_column!(new, X, :name)
			@test new == results

			new = deepcopy(short)
			add_label_column!(new, X)
			@test new == results
		end

		@testset "Simple examples" verbose = false begin

			# DataFrame definitions
			long = DataFrame(;
				name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
				val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
			)
			short = pivot(long)
			X = DataFrame(; name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
			results = DataFrame(;
				name=["aaa", "bbb", "ccc", "eee"],
				x=[true, false, false, false],
				w=[true, true, false, true],
				y=[true, false, true, false],
				z=[false, false, true, false],
				q=[true, false, false, false],
				a=[false, false, true, false],
				LABEL=[false, true, true, false],
			)
			new = deepcopy(short)

			new = deepcopy(short)
			add_label_column!(new, X, :name, :LABEL)
			@test new == results
		end
	end

	@testset "Full pipeline" verbose = false begin
		p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id)
		p_DRUG = pivot(DRUG, :person_id, :drug_concept_id)

		p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG; on=:person_id)

		add_label_column!(p_AGGREGATE, DEATH, :person_id, :death)

		@test size(p_AGGREGATE) == (100, 1878)

		@testset "top_n_values()" verbose = false begin
			@testset "ArgumentError" verbose = false begin
			end
			@testset "DomainError" verbose = false begin
			end
			@testset "MethodError" verbose = false begin
			end
			@test top_n_values(CONDITION, :condition_concept_id, 6) == DataFrame(
				AbstractVector[
					[4145513, 4064452, 4140598, 4092038, 4138456, 433753],
					[6531, 2405, 2302, 502, 390, 181],
				],
				DataFrames.Index(
					Dict(:condition_concept_id => 1, :nrow => 2),
					[:condition_concept_id, :nrow],
				),
			)
		end
	end


	@testset "Aqua.jl" verbose = false begin
		Aqua.test_all(PreprocessMD; ambiguities=false)
	end
end

#=
@testset "Template" verbose = false begin
	@testset "generic_function()" verbose = false begin
		@testset "Intended Exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin
			end
			@testset "DomainError" verbose = false begin
			end
			@testset "MethodError" verbose = false begin
			end
		end
		@testset "Default options" verbose = false begin
		end
		@testset "Simple examples" verbose = false begin
		end
	end
end
=#
