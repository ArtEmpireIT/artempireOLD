/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('transporte', {
		id_transporte: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_transporte::regclass)",
			primaryKey: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre: {
			type: DataTypes.STRING,
			allowNull: true
		},
		tonelaje: {
			type: DataTypes.STRING,
			allowNull: true
		},
		bandera: {
			type: DataTypes.STRING,
			allowNull: true
		},
		observaciones: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_transporte_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'transporte',
				key: 'id_transporte'
			}
		},
		fk_tipo_transporte: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'tipo_transporte',
				key: 'nombre_tipo'
			}
		}
	}, {
		tableName: 'transporte',
		timestamps: false
	});
};
