/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('lugar', {
		nombre: {
			type: DataTypes.STRING,
			allowNull: false
		},
		region_cont: {
			type: DataTypes.STRING,
			allowNull: true
		},
		localizacion: {
			type: DataTypes.STRING,
			allowNull: true
		},
		longitud: {
			type: DataTypes.STRING,
			allowNull: true
		},
		latitud: {
			type: DataTypes.STRING,
			allowNull: true
		},
		sistema_ref: {
			type: DataTypes.STRING,
			allowNull: true
		},
		coor_macro: {
			type: DataTypes.STRING,
			allowNull: true
		},
		coor_micro: {
			type: DataTypes.STRING,
			allowNull: true
		},
		zona: {
			type: DataTypes.STRING,
			allowNull: true
		},
		hemisferio: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_polygon_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'polygon',
				key: 'id_polygon'
			}
		},
		fk_line_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'line',
				key: 'id_line'
			}
		},
		fk_point_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'point',
				key: 'id_point'
			}
		},
		altitud: {
			type: DataTypes.STRING,
			allowNull: true
		},
		prop_geologicas: {
			type: DataTypes.STRING,
			allowNull: true
		},
		id_lugar: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_lugar::regclass)",
			primaryKey: true
		},
		fk_lugar_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'lugar',
				key: 'id_lugar'
			}
		},
		fk_tipo_lugar_nombre: {
			type: DataTypes.STRING,
			allowNull: true,
			references: {
				model: 'tipo_lugar',
				key: 'nombre'
			}
		}
	}, {
		tableName: 'lugar',
		timestamps: false
	});
};
