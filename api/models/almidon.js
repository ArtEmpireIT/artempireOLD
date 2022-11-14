/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('almidon', {
		id_almidon: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_almidon::regclass)",
			primaryKey: true
		},
		n_muestra: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		n_granos: {
			type: DataTypes.INTEGER,
			allowNull: true
		},
		morfotipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		familia: {
			type: DataTypes.STRING,
			allowNull: true
		},
		genero: {
			type: DataTypes.STRING,
			allowNull: true
		},
		especie: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		observaciones: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_muestra_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'sample',
				key: 'id_muestra'
			}
		},
		fk_almidon_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'almidon',
				key: 'id_almidon'
			}
		}
	}, {
		tableName: 'almidon',
		timestamps: false
	});
};
