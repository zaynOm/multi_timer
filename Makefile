.PHONY: release

generated_config:
	dart tools/generate_config.dart

release: generated_config
	flutter build appbundle --flavor prod